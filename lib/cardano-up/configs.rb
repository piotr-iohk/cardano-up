# frozen_string_literal: true

module CardanoUp
  # Installing configs Cardano environments
  module Configs
    # Check all necessary config files for particular environment exist.
    # @param env [String] - one of {ENVS}
    # @raise CardanoUp::EnvNotSupportedError
    def self.exist?(env)
      CardanoUp.configure_default unless CardanoUp.configured?
      raise CardanoUp::EnvNotSupportedError, env unless CardanoUp::ENVS.include?(env)

      configs = CardanoUp.config
      config_dir_env = FileUtils.mkdir_p(File.join(configs['config_dir'], env))
      config_files = CardanoUp::CONFIG_FILES
      not_existing = []
      config_files.each do |file|
        conf_file_path = File.join(config_dir_env, file)
        not_existing << conf_file_path unless File.exist?(conf_file_path)
      end
      not_existing.empty?
    end

    # Get all necessary config files for particular environment.
    # @param env [String] - one of {ENVS}
    # @raise CardanoUp::EnvNotSupportedError
    def self.get(env)
      CardanoUp.configure_default unless CardanoUp.configured?
      raise CardanoUp::EnvNotSupportedError, env unless CardanoUp::ENVS.include?(env)

      configs = CardanoUp.config
      config_urls = CardanoUp::Utils.config_urls(env)
      config_dir_env = FileUtils.mkdir_p(File.join(configs['config_dir'], env))
      config_urls.each do |url|
        CardanoUp::Utils.wget(url, File.join(config_dir_env, File.basename(url)))
      end
    end
  end
end
