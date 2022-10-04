module AdrestiaBundler
  module Start
    ##
    # Start cardano-node and cardano-wallet on your system.
    #
    # For Linux and MacOS it will attempt to start separate screen sessions for
    # wallet and node respectively, therefore 'screen' tool is required on your system.
    # @see https://www.gnu.org/software/screen/
    # If screen is not present you can install it using your package manager for instance:
    #  # MacOS:
    #  brew install screen
    #  # Linux:
    #  sudo apt-get install screen
    #
    # For Windows it will attepmt to install cardano-node and cardano-wallet as Windows services
    # using 'nssm' tool.
    # @see https://nssm.cc/
    # Nssm can be installed via choco package manager:
    #  choco install nssm
    #
    # @param env [Hash] - provide env and wallet_port, e.g. { env: 'mainnet', wallet_port: '8090' }
    # @raises AdrestiaBundler::EnvNotSupportedError
    # @raises AdrestiaBundler::WalletPortError
    def self.start_node_and_wallet(opt = { env: 'mainnet', wallet_port: '8090' })
      AdrestiaBundler.configure_default unless AdrestiaBundler.configured?
      configs = AdrestiaBundler.get_config

      env = opt[:env]
      raise AdrestiaBundler::EnvNotSupportedError.new(env) unless AdrestiaBundler::ENVS.include? env
      wallet_port = opt[:wallet_port]
      raise AdrestiaBundler::WalletPortError if (wallet_port.nil? || wallet_port.empty?)
      token_metadata_server = (env == 'mainnet') ? AdrestiaBundler::MAINNET_TOKEN_SERVER : AdrestiaBundler::TESTNET_TOKEN_SERVER

      bin_dir = configs['bin_dir']
      config_dir = File.join(configs['config_dir'], env)
      log_dir = File.join(configs['log_dir'], env)
      state_dir = File.join(configs['state_dir'], env)
      wallet_db_dir = File.join(state_dir, 'wallet-db')
      node_db_dir = File.join(state_dir, 'node-db')
      [bin_dir, config_dir, log_dir, state_dir, wallet_db_dir, node_db_dir].each do |dir|
        FileUtils.mkdir_p(dir)
      end

      if AdrestiaBundler::Utils.is_win?
        node_socket = "\\\\.\\pipe\\cardano-node-#{env}"
      else
        node_socket = File.join(state_dir, 'node.socket')
      end

      network = (env == 'mainnet') ? '--mainnet' : "--testnet #{config_dir}/byron-genesis.json"

      if AdrestiaBundler::Utils.is_win?
        # Turn off p2p for Windows
        # TODO: remove after https://github.com/input-output-hk/ouroboros-network/issues/3968 released
        config_win = JSON.parse(File.read("#{config_dir}/config.json"))
        config_win["EnableP2P"] = false
        File.open("#{config_dir}/config.json", "w") do |f|
          f.write(JSON.pretty_generate(config_win))
        end
        topology = %({
              "Producers": [
                {
                  "addr": "#{ENV['NETWORK']}-node.world.dev.cardano.org",
                  "port": 30002,
                  "valency": 2
                }
              ]
            })
        File.open("#{config_dir}/topology.json", "w") do |f|
          f.write(topology)
        end

        # create cardano-node.bat file
        node_cmd = "#{bin_dir}/cardano-node.exe run --config #{config_dir}/config.json --topology #{config_dir}/topology.json --database-path #{node_db_dir} --socket-path #{node_socket}"
        File.open("#{bin_dir}/cardano-node.bat", "w") do |f|
          f.write(node_cmd)
        end

        # create cardano-wallet.bat file
        wallet_cmd = "#{bin_dir}/cardano-wallet.exe serve --port #{wallet_port} --node-socket #{node_socket} #{network} --database #{wallet_db_dir} --token-metadata-server #{token_metadata_server}"
        File.open("#{bin_dir}/cardano-wallet.bat", "w") do |f|
          f.write(wallet_cmd)
        end
        node_service = "cardano-node-#{env}"
        wallet_service = "cardano-wallet-#{env}"
        install_node = "nssm install #{node_service} #{bin_dir}/cardano-node.bat"
        install_wallet = "nssm install #{wallet_service} #{bin_dir}/cardano-wallet.bat"
        log_stdout_node = "nssm set #{node_service} AppStdout #{log_dir}/node.log"
        log_stderr_node = "nssm set #{node_service} AppStderr #{log_dir}/node.log"
        log_stdout_wallet = "nssm set #{wallet_service} AppStdout #{log_dir}/wallet.log"
        log_stderr_wallet = "nssm set #{wallet_service} AppStderr #{log_dir}/wallet.log"
        start_node = "nssm start #{node_service}"
        start_wallet = "nssm start #{wallet_service}"

        AdrestiaBundler::Utils.cmd install_node
        AdrestiaBundler::Utils.cmd install_wallet
        AdrestiaBundler::Utils.cmd log_stdout_node
        AdrestiaBundler::Utils.cmd log_stderr_node
        AdrestiaBundler::Utils.cmd log_stdout_wallet
        AdrestiaBundler::Utils.cmd log_stderr_wallet
        AdrestiaBundler::Utils.cmd start_node
        AdrestiaBundler::Utils.cmd start_wallet
      else
        node_cmd = "#{bin_dir}/cardano-node run --config #{config_dir}/config.json --topology #{config_dir}/topology.json --database-path #{node_db_dir} --socket-path #{node_socket}"
        wallet_cmd = "#{bin_dir}/cardano-wallet serve --port #{wallet_port} --node-socket #{node_socket} #{network} --database #{wallet_db_dir} --token-metadata-server #{token_metadata_server}"
        node_service = "NODE_#{env}"
        wallet_service = "WALLET_#{env}"
        AdrestiaBundler::Utils.cmd "screen -dmS #{node_service} -L -Logfile #{log_dir}/node.log #{node_cmd}"
        AdrestiaBundler::Utils.cmd "screen -dmS #{wallet_service} -L -Logfile #{log_dir}/wallet.log #{wallet_cmd}"
      end

      {
        node: {
          service: node_service,
          cmd: node_cmd,
          log: "#{log_dir}/node.log",
          db_dir: node_db_dir,
          socket_path: node_socket,
          protocol_magic: get_protocol_magic(config_dir),
          network: env
        },
        wallet: {
          service: wallet_service,
          log: "#{log_dir}/wallet.log",
          db_dir: wallet_db_dir,
          cmd: wallet_cmd,
          port: wallet_port.to_i,
          host: "http://localhost:#{wallet_port}/v2"
        }
      }
    end

    # @raises AdrestiaBundler::EnvNotSupportedError
    def self.stop_node_and_wallet(env)
      raise AdrestiaBundler::EnvNotSupportedError.new(env) unless AdrestiaBundler::ENVS.include? env
      if AdrestiaBundler::Utils.is_win?
        AdrestiaBundler::Utils.cmd "nssm stop cardano-wallet-#{env}"
        AdrestiaBundler::Utils.cmd "nssm stop cardano-node-#{env}"

        AdrestiaBundler::Utils.cmd "nssm remove cardano-wallet-#{env} confirm"
        AdrestiaBundler::Utils.cmd "nssm remove cardano-node-#{env} confirm"
      else
        AdrestiaBundler::Utils.cmd "screen -XS WALLET_#{env} quit"
        AdrestiaBundler::Utils.cmd "screen -S NODE_#{env} -X at '0' stuff '^C'"
        AdrestiaBundler::Utils.cmd "screen -XS NODE_#{env} quit"
        # puts "⚠️ NOTE! It seems that screen is not able to kill cardano-node properly. ⚠️"
        # puts "Run: "
        # puts "  $ screen -r NODE_#{env}"
        # puts "And hit: Ctrl + C"
      end
    end

    ##
    # Get protocol magic from config's byron-genesis.json
    def get_protocol_magic(config)
      byron_genesis = JSON.parse(File.read(File.join(config, "byron-genesis.json")))
      byron_genesis['protocolConsts']['protocolMagic'].to_i
    end
    module_function :get_protocol_magic
    private_class_method :get_protocol_magic
  end
end
