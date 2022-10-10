# frozen_string_literal: true

require 'rubygems'
require 'rubygems/package'
require 'httparty'
require 'fileutils'
require 'file-tail'
require 'json'
require 'zlib'
require 'zip'

require 'cardano-up/version'
require 'cardano-up/err'
require 'cardano-up/utils'
require 'cardano-up/tar'
require 'cardano-up/bins'
require 'cardano-up/configs'
require 'cardano-up/start'
require 'cardano-up/tail'

# Cardano Up!
# Lightweight manager for Cardano binaries and configs.
module CardanoUp
  CONFIGS_BASE_URL = 'https://book.world.dev.cardano.org/environments'
  BINS_BASE_URL = 'https://github.com/input-output-hk/cardano-wallet'
  HYDRA_BASE_URL = 'https://hydra.iohk.io/job/Cardano/cardano-wallet'
  ENVS = %w[mainnet preview preprod shelley-qa
            staging vasil-qa vasil-dev mixed testnet].freeze
  CONFIG_FILES = ['alonzo-genesis.json', 'byron-genesis.json', 'shelley-genesis.json',
                  'config.json', 'topology.json'].freeze
  MAINNET_TOKEN_SERVER = 'https://tokens.cardano.org'
  TESTNET_TOKEN_SERVER = 'https://metadata.cardano-testnet.iohkdev.io'
  # It is recommended to use default value for {base_dir},
  # however it is possible to modify it with {base_dir=}.
  @base_dir = File.join(Dir.home, '.cardano-up')

  # It is recommended to use default value for {cardano_up_config},
  # however it is possible to modify it with {cardano_up_config=}.
  @cardano_up_config = File.join(@base_dir, '.cardano-up.json')

  def self.base_dir
    @base_dir
  end

  def self.base_dir=(value)
    @base_dir = value
    @cardano_up_config = File.join(@base_dir, 'config.json')
    @base_dir
  end

  def self.cardano_up_config
    @cardano_up_config
  end

  def self.cardano_up_config=(value)
    @cardano_up_config = value
  end

  # Check if CardanoUp config exists
  def self.configured?
    File.exist?(@cardano_up_config)
  end

  # Set default config for CardanoUp
  def self.configure_default
    configure(File.join(@base_dir, 'bins'),
              File.join(@base_dir, 'state'),
              File.join(@base_dir, 'logs'),
              File.join(@base_dir, 'configs'))
  end

  # Set custom config for CardanoUp
  def self.configure(bin_dir, state_dir, logs_dir, config_dir)
    FileUtils.mkdir_p(@base_dir)
    c = if configured?
          CardanoUp.config
        else
          { 'bin_dir' => File.join(@base_dir, 'bins'),
            'state_dir' => File.join(@base_dir, 'state'),
            'log_dir' => File.join(@base_dir, 'state'),
            'config_dir' => File.join(@base_dir, 'configs') }
        end
    c['bin_dir'] = bin_dir if bin_dir
    c['state_dir'] = state_dir if state_dir
    c['log_dir'] = logs_dir if logs_dir
    c['config_dir'] = config_dir if config_dir
    File.write(@cardano_up_config, JSON.pretty_generate(c))
    JSON.parse(File.read(@cardano_up_config))
  end

  # Get config values
  def self.config
    raise CardanoUp::ConfigNotSetError unless configured?

    JSON.parse(File.read(@cardano_up_config))
  end

  # Remove configuration file
  def self.remove_cardano_up_config
    FileUtils.rm_f(@cardano_up_config)
  end

  # dir [String] config dir
  def self.clean_config_dir(dir)
    FileUtils.rm_f(config[dir])
  end
end
