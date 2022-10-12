# frozen_string_literal: true

module CardanoUp
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

  # Thrown when version of bundle to download is not supported
  class VersionNotSupportedError < StandardError
    def initialize(ver)
      super(["Not supported version: #{ver}. Supported are: 'latest', 'master',",
             "tag (e.g. 'v2022-08-16') or pr number ('3045')"].join(' '))
    end
  end
end
