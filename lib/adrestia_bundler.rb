require 'httparty'
require 'fileutils'

require "adrestia_bundler/version"
require "adrestia_bundler/utils"

module AdrestiaBundler
  CONFIGS_BASE_URL = 'https://book.world.dev.cardano.org/environments'
  BINS_BASE_URL = 'https://github.com/input-output-hk/cardano-wallet'
  HYDRA_BASE_URL = 'https://hydra.iohk.io/job/Cardano/cardano-wallet'
  ENVS = ['mainnet', 'preview', 'preprod', 'shelley-qa',
          'staging', 'vasil-qa', 'vasil-dev', 'mixed', 'testnet']

  class EnvNotSupportedError < StandardError
    def initialize(env)
      super("Environment '#{env}' not supported. Supported are: #{ENVS}")
    end
  end

  def self.init
    puts "Init"
  end
end
