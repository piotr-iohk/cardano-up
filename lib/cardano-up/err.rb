# frozen_string_literal: true

module CardanoUp
  class EnvNotSupportedError < StandardError
    def initialize(env)
      super("Environment '#{env}' not supported. Supported are: #{ENVS}")
    end
  end

  class ConfigNotSetError < StandardError
    def initialize
      super("Config not exists at '#{CardanoUp.adrestia_bundler_config}'!")
    end
  end

  class WalletPortError < StandardError
    def initialize
      super('Wallet port is not set!')
    end
  end

  class VersionNotSupportedError < StandardError
    def initialize(ver)
      super("Not supported version: #{ver}. Supported are: 'latest', 'master', tag (e.g. 'v2022-08-16') or pr number ('3045')")
    end
  end
end
