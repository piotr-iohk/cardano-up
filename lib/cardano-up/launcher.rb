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
    # @param env [Hash] provide env and wallet_port,
    #  e.g. { env: 'mainnet', wallet_port: '8090', session_name: '0' }
    # @raise CardanoUp::EnvNotSupportedError
    # @raise CardanoUp::WalletPortError
    def self.setup(opt = { env: 'mainnet', wallet_port: '8090', session_name: '0' })
      env = opt[:env]
      raise CardanoUp::EnvNotSupportedError, env unless CardanoUp::ENVS.include? env

      wallet_port = opt[:wallet_port]
      raise CardanoUp::WalletPortError if wallet_port.nil? || wallet_port.empty?

      session_name = opt[:session_name] || '0'

      token_metadata_server = env == 'mainnet' ? CardanoUp::MAINNET_TOKEN_SERVER : CardanoUp::TESTNET_TOKEN_SERVER

      CardanoUp.configure_default unless CardanoUp.configured?
      configs = CardanoUp.config
      bin_dir = configs[:bin_dir]
      config_dir = File.join(configs[:config_dir], env)
      log_dir = File.join(configs[:log_dir], session_name, env)
      state_dir = File.join(configs[:state_dir], session_name, env)
      wallet_db_dir = File.join(state_dir, 'wallet-db')
      node_db_dir = File.join(state_dir, 'node-db')
      [bin_dir, config_dir, log_dir, state_dir, wallet_db_dir, node_db_dir].each do |dir|
        FileUtils.mkdir_p(dir)
      end

      node_socket = if CardanoUp::Utils.win?
                      "\\\\.\\pipe\\cardano-node-#{env}-#{session_name}"
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
        network: network,
        session_name: session_name
      }
    end

    # @param configuration [Hash] output of setup
    # @raise CardanoUp::SessionHasNodeError
    # @raise CardanoUp::SessionHasWalletError
    # @raise CardanoUp::NoScreenError
    def self.node_up(configuration)
      env = configuration[:env]
      bin_dir = configuration[:bin_dir]
      config_dir = configuration[:config_dir]
      log_dir = configuration[:log_dir]
      node_db_dir = configuration[:node_db_dir]
      node_socket = configuration[:node_socket]
      session_name = configuration[:session_name]

      raise CardanoUp::NoScreenError if !CardanoUp::Utils.win? && !CardanoUp::Utils.screen?

      exe = CardanoUp::Utils.win? ? '.exe' : ''
      cardano_node = "#{File.join(bin_dir, 'cardano-node')}#{exe}"
      version = CardanoUp::Utils.cmd "#{cardano_node} version"
      node_cmd = ["#{cardano_node} run",
                  "--config #{File.join(config_dir, 'config.json')}",
                  "--topology #{File.join(config_dir, 'topology.json')}",
                  "--database-path #{node_db_dir}",
                  "--socket-path #{node_socket}"].join(' ')
      node_service = if CardanoUp::Utils.win?
                       "cardano-node-#{env}-#{session_name}"
                     else
                       "NODE_#{env}_#{session_name}"
                     end
      logfile = File.join(log_dir, 'node.log')
      service_details = {
        network: env,
        node: {
          service: node_service,
          version: version,
          log: logfile,
          db_dir: node_db_dir,
          socket_path: node_socket,
          protocol_magic: get_protocol_magic(config_dir),
          bin: node_cmd.split.first,
          cmd: node_cmd
        }
      }
      CardanoUp::Session.create_or_update(session_name, service_details)
      if CardanoUp::Utils.win?
        # Turn off p2p for Windows
        # TODO: remove after https://github.com/input-output-hk/ouroboros-network/issues/3968 released
        config_win = CardanoUp::Utils.from_json("#{config_dir}/config.json")
        config_win[:EnableP2P] = false
        CardanoUp::Utils.to_json("#{config_dir}/config.json", config_win)
        topology = {
          Producers: [
            {
              addr: "#{env}-node.world.dev.cardano.org",
              port: 30_002,
              valency: 2
            }
          ]
        }
        CardanoUp::Utils.to_json("#{config_dir}/topology.json", topology)

        # create cardano-node.bat file
        File.write("#{bin_dir}/cardano-node.bat", node_cmd)
        install_node = "nssm install #{node_service} #{bin_dir}/cardano-node.bat"
        log_stdout_node = "nssm set #{node_service} AppStdout #{logfile}"
        log_stderr_node = "nssm set #{node_service} AppStderr #{logfile}"
        start_node = "nssm start #{node_service}"

        CardanoUp::Utils.cmd install_node
        CardanoUp::Utils.cmd log_stdout_node
        CardanoUp::Utils.cmd log_stderr_node
        CardanoUp::Utils.cmd start_node
      else
        screen_cmd = "screen -dmS #{node_service} -L -Logfile #{logfile} #{node_cmd}"
        CardanoUp::Utils.cmd screen_cmd
      end
      service_details
    end

    # @param configuration [Hash] output of setup
    # @raise CardanoUp::NoScreenError
    # @raise CardanoUp::WalletPortUsedError
    def self.wallet_up(configuration)
      if CardanoUp::Utils.port_used?(configuration[:wallet_port].to_i)
        raise CardanoUp::WalletPortUsedError, configuration[:wallet_port]
      end

      raise CardanoUp::NoScreenError if !CardanoUp::Utils.win? && !CardanoUp::Utils.screen?

      env = configuration[:env]
      wallet_port = configuration[:wallet_port]
      token_metadata_server = configuration[:token_metadata_server]
      bin_dir = configuration[:bin_dir]
      log_dir = configuration[:log_dir]
      wallet_db_dir = configuration[:wallet_db_dir]
      node_socket = configuration[:node_socket]
      network = configuration[:network]
      session_name = configuration[:session_name]

      exe = CardanoUp::Utils.win? ? '.exe' : ''
      cardano_wallet = "#{File.join(bin_dir, 'cardano-wallet')}#{exe}"
      wallet_cmd = ["#{cardano_wallet} serve",
                    "--port #{wallet_port}",
                    "--node-socket #{node_socket}",
                    network.to_s,
                    "--database #{wallet_db_dir}",
                    "--token-metadata-server #{token_metadata_server}"].join(' ')
      version = CardanoUp::Utils.cmd "#{bin_dir}/cardano-wallet#{exe} version"
      wallet_service = if CardanoUp::Utils.win?
                         "cardano-wallet-#{env}-#{session_name}"
                       else
                         "WALLET_#{env}_#{session_name}"
                       end
      logfile = File.join(log_dir, 'wallet.log')
      service_details = {
        network: env,
        wallet: {
          service: wallet_service,
          version: version,
          log: logfile,
          db_dir: wallet_db_dir,
          port: wallet_port.to_i,
          url: "http://localhost:#{wallet_port}/v2",
          bin: wallet_cmd.split.first,
          cmd: wallet_cmd
        }
      }

      CardanoUp::Session.create_or_update(session_name, service_details)
      if CardanoUp::Utils.win?
        # create cardano-wallet.bat file
        File.write("#{bin_dir}/cardano-wallet.bat", wallet_cmd)
        install_wallet = "nssm install #{wallet_service} #{bin_dir}/cardano-wallet.bat"
        log_stdout_wallet = "nssm set #{wallet_service} AppStdout #{logfile}"
        log_stderr_wallet = "nssm set #{wallet_service} AppStderr #{logfile}"
        start_wallet = "nssm start #{wallet_service}"

        CardanoUp::Utils.cmd install_wallet
        CardanoUp::Utils.cmd log_stdout_wallet
        CardanoUp::Utils.cmd log_stderr_wallet
        CardanoUp::Utils.cmd start_wallet
      else
        CardanoUp::Utils.cmd "screen -dmS #{wallet_service} -L -Logfile #{logfile} #{wallet_cmd}"
      end

      service_details
    end

    # @raise CardanoUp::EnvNotSupportedError
    # @raise CardanoUp::NoScreenError
    def self.node_down(env, session_name = '0')
      raise CardanoUp::EnvNotSupportedError, env unless CardanoUp::ENVS.include? env

      raise CardanoUp::NoScreenError if !CardanoUp::Utils.win? && !CardanoUp::Utils.screen?

      if CardanoUp::Utils.win?
        CardanoUp::Utils.cmd "nssm stop cardano-node-#{env}-#{session_name}"
        CardanoUp::Utils.cmd "nssm remove cardano-node-#{env}-#{session_name} confirm"
      else
        CardanoUp::Utils.cmd "screen -S NODE_#{env}_#{session_name} -X at '0' stuff '^C'"
        CardanoUp::Utils.cmd "screen -XS NODE_#{env}_#{session_name} quit"
      end
      CardanoUp::Session.remove(session_name, { network: env, service: 'node' })
    end

    # @raise CardanoUp::EnvNotSupportedError
    # @raise CardanoUp::NoScreenError
    def self.wallet_down(env, session_name = '0')
      raise CardanoUp::EnvNotSupportedError, env unless CardanoUp::ENVS.include? env

      raise CardanoUp::NoScreenError if !CardanoUp::Utils.win? && !CardanoUp::Utils.screen?

      if CardanoUp::Utils.win?
        CardanoUp::Utils.cmd "nssm stop cardano-wallet-#{env}-#{session_name}"
        CardanoUp::Utils.cmd "nssm remove cardano-wallet-#{env}-#{session_name} confirm"
      else
        CardanoUp::Utils.cmd "screen -S WALLET_#{env}_#{session_name} -X at '0' stuff '^C'"
        CardanoUp::Utils.cmd "screen -XS WALLET_#{env}_#{session_name} quit"
      end
      CardanoUp::Session.remove(session_name, { network: env, service: 'wallet' })
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
