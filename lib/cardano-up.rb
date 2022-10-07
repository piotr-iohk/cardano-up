require 'rubygems'
require 'rubygems/package'
require 'httparty'
require 'fileutils'
require 'file-tail'
require 'json'
require 'zlib'
require 'zip'

require "cardano-up/version"
require "cardano-up/err"
require "cardano-up/utils"
require "cardano-up/tar"
require "cardano-up/install"
require "cardano-up/start"
require "cardano-up/tail"

module CardanoUp
  CONFIGS_BASE_URL = 'https://book.world.dev.cardano.org/environments'
  BINS_BASE_URL = 'https://github.com/input-output-hk/cardano-wallet'
  HYDRA_BASE_URL = 'https://hydra.iohk.io/job/Cardano/cardano-wallet'
  ENVS = ['mainnet', 'preview', 'preprod', 'shelley-qa',
          'staging', 'vasil-qa', 'vasil-dev', 'mixed', 'testnet']
  CONFIG_FILES = ['alonzo-genesis.json', 'byron-genesis.json', 'shelley-genesis.json',
                  'config.json', 'topology.json']
  MAINNET_TOKEN_SERVER = 'https://tokens.cardano.org'
  TESTNET_TOKEN_SERVER = 'https://metadata.cardano-testnet.iohkdev.io'
  # It is recommended to use default value for {base_dir},
  # however it is possible to modify it with {base_dir=}.
  @@base_dir = File.join(Dir.home, '.cardano-up')

  # It is recommended to use default value for {adrestia_bundler_config},
  # however it is possible to modify it with {adrestia_bundler_config=}.
  @@adrestia_bundler_config = File.join(@@base_dir, '.cardano-up.json')

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

  # Check if CardanoUp config exists
  def self.configured?
    File.exists?(@@adrestia_bundler_config)
  end

  # Set default config for CardanoUp
  def self.configure_default
    configure(File.join(@@base_dir, 'bins'),
              File.join(@@base_dir, 'state'),
              File.join(@@base_dir, 'logs'),
              File.join(@@base_dir, 'configs'))
  end

  # Set custom config for CardanoUp
  def self.configure(bin_dir, state_dir, logs_dir, config_dir)
    FileUtils.mkdir_p(@@base_dir)
    if configured?
      c = CardanoUp.get_config
    else
      c = { 'bin_dir' => File.join(@@base_dir, 'bins'),
             'state_dir' => File.join(@@base_dir, 'state'),
             'log_dir' => File.join(@@base_dir, 'state'),
             'config_dir' => File.join(@@base_dir, 'configs')
            }
    end
    c['bin_dir'] = bin_dir if bin_dir
    c['state_dir'] = state_dir if state_dir
    c['log_dir'] = logs_dir if logs_dir
    c['config_dir'] = config_dir if config_dir
    File.write(@@adrestia_bundler_config, JSON.pretty_generate(c))
    JSON.parse(File.read(@@adrestia_bundler_config))
  end

  # Get config values
  def self.get_config
    raise CardanoUp::ConfigNotSetError unless configured?
    JSON.parse(File.read(@@adrestia_bundler_config))
  end

  # Remove configuration
  def self.remove_configuration
    FileUtils.rm_f(@@adrestia_bundler_config)
  end
end
