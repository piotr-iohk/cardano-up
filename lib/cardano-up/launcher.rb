# frozen_string_literal: true

module CardanoUp
  ##
  # Start/stop cardano-node and cardano-wallet on your system.
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
  module Launcher
    # Create common set of variables for getting node and wallet up
    # @param env [Hash] provide env and wallet_port, e.g. { env: 'mainnet', wallet_port: '8090' }
    # @raise CardanoUp::EnvNotSupportedError
    # @raise CardanoUp::WalletPortError
    def self.setup(opt = { env: 'mainnet', wallet_port: '8090' })
      env = opt[:env]
      raise CardanoUp::EnvNotSupportedError, env unless CardanoUp::ENVS.include? env

      wallet_port = opt[:wallet_port]
      raise CardanoUp::WalletPortError if wallet_port.nil? || wallet_port.empty?

      token_metadata_server = env == 'mainnet' ? CardanoUp::MAINNET_TOKEN_SERVER : CardanoUp::TESTNET_TOKEN_SERVER

      CardanoUp.configure_default unless CardanoUp.configured?
      configs = CardanoUp.config
      bin_dir = configs['bin_dir']
      config_dir = File.join(configs['config_dir'], env)
      log_dir = File.join(configs['log_dir'], env)
      state_dir = File.join(configs['state_dir'], env)
      wallet_db_dir = File.join(state_dir, 'wallet-db')
      node_db_dir = File.join(state_dir, 'node-db')
      [bin_dir, config_dir, log_dir, state_dir, wallet_db_dir, node_db_dir].each do |dir|
        FileUtils.mkdir_p(dir)
      end

      node_socket = if CardanoUp::Utils.win?
                      "\\\\.\\pipe\\cardano-node-#{env}"
                    else
                      File.join(state_dir, 'node.socket')
                    end
      network = env == 'mainnet' ? '--mainnet' : "--testnet #{File.join(config_dir, 'byron-genesis.json')}"

      {
        env: env,
        wallet_port: wallet_port,
        token_metadata_server: token_metadata_server,
        bin_dir: bin_dir,
        config_dir: config_dir,
        log_dir: log_dir,
        state_dir: state_dir,
        wallet_db_dir: wallet_db_dir,
        node_db_dir: node_db_dir,
        node_socket: node_socket,
        network: network
      }
    end

    # @param configuration [Hash] output of setup
    def self.node_up(configuration)
      env = configuration[:env]
      bin_dir = configuration[:bin_dir]
      config_dir = configuration[:config_dir]
      log_dir = configuration[:log_dir]
      node_db_dir = configuration[:node_db_dir]
      node_socket = configuration[:node_socket]

      exe = CardanoUp::Utils.win? ? '.exe' : ''
      version = CardanoUp::Utils.cmd "#{bin_dir}/cardano-node#{exe} version"

      if CardanoUp::Utils.win?
        # Turn off p2p for Windows
        # TODO: remove after https://github.com/input-output-hk/ouroboros-network/issues/3968 released
        config_win = CardanoUp::Utils.from_json("#{config_dir}/config.json")
        config_win[:EnableP2P] = false
        CardanoUp::Utils.to_json("#{config_dir}/config.json", config_win)
        topology = %({
              "Producers": [
                {
                  "addr": "#{env}-node.world.dev.cardano.org",
                  "port": 30002,
                  "valency": 2
                }
              ]
            })
        CardanoUp::Utils.to_json("#{config_dir}/topology.json", topology)

        # create cardano-node.bat file
        node_cmd = ["#{File.join(bin_dir, 'cardano-node.exe')} run",
                    "--config #{File.join(config_dir, 'config.json')}",
                    "--topology #{File.join(config_dir, 'topology.json')}",
                    "--database-path #{node_db_dir}",
                    "--socket-path #{node_socket}"].join(' ')
        File.write("#{bin_dir}/cardano-node.bat", node_cmd)
        node_service = "cardano-node-#{env}"
        install_node = "nssm install #{node_service} #{bin_dir}/cardano-node.bat"
        log_stdout_node = "nssm set #{node_service} AppStdout #{log_dir}/node.log"
        log_stderr_node = "nssm set #{node_service} AppStderr #{log_dir}/node.log"
        start_node = "nssm start #{node_service}"

        CardanoUp::Utils.cmd install_node
        CardanoUp::Utils.cmd log_stdout_node
        CardanoUp::Utils.cmd log_stderr_node
        CardanoUp::Utils.cmd start_node
      else
        node_cmd = ["#{File.join(bin_dir, 'cardano-node')} run",
                    "--config #{File.join(config_dir, 'config.json')}",
                    "--topology #{File.join(config_dir, 'topology.json')}",
                    "--database-path #{node_db_dir}",
                    "--socket-path #{node_socket}"].join(' ')
        node_service = "NODE_#{env}"
        screen_cmd = "screen -dmS #{node_service} -L -Logfile #{log_dir}/node.log #{node_cmd}"
        CardanoUp::Utils.cmd screen_cmd
      end

      {
        network: env,
        node: {
          service: node_service,
          version: version,
          log: "#{log_dir}/node.log",
          db_dir: node_db_dir,
          socket_path: node_socket,
          protocol_magic: get_protocol_magic(config_dir),
          bin: node_cmd.split.first,
          cmd: node_cmd
        }
      }
    end

    # @param configuration [Hash] output of setup
    def self.wallet_up(configuration)
      env = configuration[:env]
      wallet_port = configuration[:wallet_port]
      token_metadata_server = configuration[:token_metadata_server]
      bin_dir = configuration[:bin_dir]
      log_dir = configuration[:log_dir]
      wallet_db_dir = configuration[:wallet_db_dir]
      node_socket = configuration[:node_socket]
      network = configuration[:network]

      exe = CardanoUp::Utils.win? ? '.exe' : ''
      version = CardanoUp::Utils.cmd "#{bin_dir}/cardano-wallet#{exe} version"

      if CardanoUp::Utils.win?

        # create cardano-wallet.bat file
        wallet_cmd = ["#{File.join(bin_dir, 'cardano-wallet.exe')} serve",
                      "--port #{wallet_port}",
                      "--node-socket #{node_socket}",
                      network.to_s,
                      "--database #{wallet_db_dir}",
                      "--token-metadata-server #{token_metadata_server}"].join(' ')
        File.write("#{bin_dir}/cardano-wallet.bat", wallet_cmd)
        wallet_service = "cardano-wallet-#{env}"
        install_wallet = "nssm install #{wallet_service} #{bin_dir}/cardano-wallet.bat"
        log_stdout_wallet = "nssm set #{wallet_service} AppStdout #{log_dir}/wallet.log"
        log_stderr_wallet = "nssm set #{wallet_service} AppStderr #{log_dir}/wallet.log"
        start_wallet = "nssm start #{wallet_service}"

        CardanoUp::Utils.cmd install_wallet
        CardanoUp::Utils.cmd log_stdout_wallet
        CardanoUp::Utils.cmd log_stderr_wallet
        CardanoUp::Utils.cmd start_wallet
      else
        wallet_cmd = ["#{File.join(bin_dir, 'cardano-wallet')} serve",
                      "--port #{wallet_port}",
                      "--node-socket #{node_socket}",
                      network.to_s,
                      "--database #{wallet_db_dir}",
                      "--token-metadata-server #{token_metadata_server}"].join(' ')
        wallet_service = "WALLET_#{env}"
        CardanoUp::Utils.cmd "screen -dmS #{wallet_service} -L -Logfile #{log_dir}/wallet.log #{wallet_cmd}"
      end

      {
        network: env,
        wallet: {
          service: wallet_service,
          version: version,
          log: "#{log_dir}/wallet.log",
          db_dir: wallet_db_dir,
          port: wallet_port.to_i,
          host: "http://localhost:#{wallet_port}/v2",
          bin: wallet_cmd.split.first,
          cmd: wallet_cmd
        }
      }
    end

    # @raise CardanoUp::EnvNotSupportedError
    def self.node_down(env)
      raise CardanoUp::EnvNotSupportedError, env unless CardanoUp::ENVS.include? env

      if CardanoUp::Utils.win?
        CardanoUp::Utils.cmd "nssm stop cardano-node-#{env}"
        CardanoUp::Utils.cmd "nssm remove cardano-node-#{env} confirm"
      else
        CardanoUp::Utils.cmd "screen -S NODE_#{env} -X at '0' stuff '^C'"
        CardanoUp::Utils.cmd "screen -XS NODE_#{env} quit"
      end
    end

    # @raise CardanoUp::EnvNotSupportedError
    def self.wallet_down(env)
      raise CardanoUp::EnvNotSupportedError, env unless CardanoUp::ENVS.include? env

      if CardanoUp::Utils.win?
        CardanoUp::Utils.cmd "nssm stop cardano-wallet-#{env}"
        CardanoUp::Utils.cmd "nssm remove cardano-wallet-#{env} confirm"
      else
        CardanoUp::Utils.cmd "screen -S WALLET_#{env} -X at '0' stuff '^C'"
        CardanoUp::Utils.cmd "screen -XS WALLET_#{env} quit"
      end
    end

    ##
    # Get protocol magic from config's byron-genesis.json
    def get_protocol_magic(config)
      byron_genesis = CardanoUp::Utils.from_json(File.join(config, 'byron-genesis.json'))
      byron_genesis[:protocolConsts][:protocolMagic].to_i
    end
    module_function :get_protocol_magic
    private_class_method :get_protocol_magic
  end
end
