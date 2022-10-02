require 'httparty'
require 'fileutils'
require 'json'

require "adrestia_bundler/version"
require "adrestia_bundler/utils"

module AdrestiaBundler
  CONFIGS_BASE_URL = 'https://book.world.dev.cardano.org/environments'
  BINS_BASE_URL = 'https://github.com/input-output-hk/cardano-wallet'
  HYDRA_BASE_URL = 'https://hydra.iohk.io/job/Cardano/cardano-wallet'
  ENVS = ['mainnet', 'preview', 'preprod', 'shelley-qa',
          'staging', 'vasil-qa', 'vasil-dev', 'mixed', 'testnet']

  # It is recommended to use default values for {base_dir},
  # however it is possible to modify it with {base_dir=}.
  @@base_dir = File.join(Dir.home, '.adrestia-bundler')

  # It is recommended to use default values for {adrestia_bundler_config},
  # however it is possible to modify it with {adrestia_bundler_config=}.
  @@adrestia_bundler_config = File.join(@@base_dir, 'config.json')

  def self.base_dir
    @@base_dir
  end

  def self.base_dir=(value)
    @@base_dir = value
    @@adrestia_bundler_config = File.join(@@base_dir, 'config.json')
    @@base_dir
  end

  def self.adrestia_bundler_config
    @@adrestia_bundler_config
  end

  def self.adrestia_bundler_config=(value)
    @@adrestia_bundler_config = value
  end

  # Check if AdrestiaBundler config exists
  def self.configured?
    File.exists?(@@adrestia_bundler_config)
  end

  # Set default config for AdrestiaBundler
  def self.configure_default
    configure(File.join(@@base_dir, 'bins'),
              File.join(@@base_dir, 'state'),
              File.join(@@base_dir, 'logs'),
              File.join(@@base_dir, 'configs'))
  end

  # Set custom config for AdrestiaBundler
  def self.configure(bin_dir, state_dir, logs_dir, config_dir)
    config = { 'bin_dir' => bin_dir,
               'state_dir' => state_dir,
               'log_dir' => logs_dir,
               'config_dir' => config_dir
              }
    FileUtils.mkdir_p(@@base_dir)
    File.write(@@adrestia_bundler_config, config.to_json)
    JSON.parse(File.read(@@adrestia_bundler_config))
  end

  # Get config values
  def self.get_config
    raise AdrestiaBundler::ConfigNotSetError unless configured?
    JSON.parse(File.read(@@adrestia_bundler_config))
  end

  # Remove configuration
  def self.remove_configuration
    FileUtils.rm_f(@@adrestia_bundler_config)
  end

  ## Exceptions

  class EnvNotSupportedError < StandardError
    def initialize(env)
      super("Environment '#{env}' not supported. Supported are: #{ENVS}")
    end
  end

  class ConfigNotSetError < StandardError
    def initialize
      super("Config not exists at '#{AdrestiaBundler::adrestia_bundler_config}'!")
    end
  end

end
