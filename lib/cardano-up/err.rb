# frozen_string_literal: true

module CardanoUp
  # Thrown when service not exists in session
  class SessionServiceNotUpError < StandardError
    def initialize(session_name, env, service)
      super("Service '#{service}' is not running on '#{env}' in session '#{session_name}'!")
    end
  end

  # Thrown when env not exists in session
  class SessionEnvNotUpError < StandardError
    def initialize(session_name, env)
      super("Nothing is running on '#{env}' in session '#{session_name}'!")
    end
  end

  # Thrown when session not exists
  class SessionNotExistsError < StandardError
    def initialize(session_name)
      super("Session '#{session_name}' does not exist!")
    end
  end

  # Thrown when there is already a node running in the session
  class SessionHasNodeError < StandardError
    def initialize(session_name, network)
      super("Session '#{session_name}' already has node running on '#{network}'!")
    end
  end

  # Thrown when there is already a wallet running in the session
  class SessionHasWalletError < StandardError
    def initialize(session_name, network)
      super("Session '#{session_name}' already has wallet running on '#{network}'!")
    end
  end

  # Thrown when env is not supported
  class EnvNotSupportedError < StandardError
    def initialize(env)
      super("Environment '#{env}' not supported. Supported are: #{ENVS}")
    end
  end

  # Thrown when cardano_up internal config does not exists
  class ConfigNotSetError < StandardError
    def initialize
      super("Config not exists at '#{CardanoUp.cardano_up_config}'!")
    end
  end

  # Thrown when wallet port is not set
  class WalletPortError < StandardError
    def initialize
      super('Wallet port is not set!')
    end
  end

  # Thrown when wallet port is not set
  class WalletPortUsedError < StandardError
    def initialize(port)
      super("The port #{port} is already in use!")
    end
  end

  # Thrown when version of bundle to download is not supported
  class VersionNotSupportedError < StandardError
    def initialize(ver)
      super(["Not supported version: #{ver}. Supported are: 'latest', 'master',",
             "tag (e.g. 'v2022-08-16') or pr number ('3045')"].join(' '))
    end
  end
end
