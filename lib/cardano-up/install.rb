# frozen_string_literal: true

module CardanoUp
  module Install
    # Check all necessary config files for particular environment exist.
    # @param env [String] - one of {ENVS}
    # @raise CardanoUp::EnvNotSupportedError
    def self.configs_exist?(env)
      CardanoUp.configure_default unless CardanoUp.configured?
      raise CardanoUp::EnvNotSupportedError, env unless CardanoUp::ENVS.include?(env)

      configs = CardanoUp.get_config
      config_dir_env = FileUtils.mkdir_p(File.join(configs['config_dir'], env))
      config_files = CardanoUp::CONFIG_FILES
      not_existing = []
      config_files.each do |file|
        conf_file_path = File.join(config_dir_env, file)
        not_existing << conf_file_path unless File.exist?(conf_file_path)
      end
      if not_existing.empty?
        true
      else
        false
      end
    end

    # Get all necessary config files for particular environment.
    # @param env [String] - one of {ENVS}
    # @raise CardanoUp::EnvNotSupportedError
    def self.install_configs(env)
      CardanoUp.configure_default unless CardanoUp.configured?
      raise CardanoUp::EnvNotSupportedError, env unless CardanoUp::ENVS.include?(env)

      configs = CardanoUp.get_config
      config_urls = CardanoUp::Utils.get_config_urls(env)
      config_dir_env = FileUtils.mkdir_p(File.join(configs['config_dir'], env))
      config_urls.each do |url|
        CardanoUp::Utils.wget(url, File.join(config_dir_env, File.basename(url)))
      end
    end

    # Get cardano-wallet bundle binaries to your computer.
    # @param release [String] - 'latest' | /^v20.{2}-.{2}-.{2}/ | 'master' | '3341'
    # @raise CardanoUp::VersionNotSupportedError
    def self.install_bins(release)
      CardanoUp.configure_default unless CardanoUp.configured?
      configs = CardanoUp.get_config
      url = CardanoUp::Utils.get_binary_url(release)
      bin_dir_env = FileUtils.mkdir_p(configs['bin_dir']).first
      file_to_unpack = File.join(bin_dir_env, 'binary-dist')
      CardanoUp::Utils.wget(url, file_to_unpack)

      unpack_binary(file_to_unpack, bin_dir_env)
      return_versions(bin_dir_env)
    end

    def unpack_binary(file_path, destination)
      if CardanoUp::Utils.is_win?
        CardanoUp::Tar.unzip(file_path, destination)
      else
        gio = CardanoUp::Tar.ungzip(File.open(file_path, 'rb'))
        CardanoUp::Tar.untar(gio, destination)
        cw_dir = Dir[File.join(destination, '/cardano-wallet-*')].first
        FileUtils.cp_r(Dir[File.join(cw_dir, '/*')], destination)
        FileUtils.rm_rf(file_path)
        FileUtils.rm_rf(cw_dir)
        executables = Dir[File.join(destination, '/cardano-*')] << File.join(destination, '/bech32')
        executables.each { |e| FileUtils.chmod('u+x', e) }
        executables
      end
    end
    module_function :unpack_binary
    private_class_method :unpack_binary

    # Return versions of installed components
    # @raise CardanoUp::ConfigNotSetError
    def self.return_versions(bin_dir = nil)
      bindir = bin_dir.nil? ? CardanoUp.get_config['bin_dir'] : bin_dir
      exe = CardanoUp::Utils.is_win? ? '.exe' : ''
      cn = CardanoUp::Utils.cmd "#{bindir}/cardano-node#{exe} version"
      cli = CardanoUp::Utils.cmd "#{bindir}/cardano-cli#{exe} version"
      cw = CardanoUp::Utils.cmd "#{bindir}/cardano-wallet#{exe} version"
      ca = CardanoUp::Utils.cmd "#{bindir}/cardano-address#{exe} version"
      b32 = CardanoUp::Utils.cmd "#{bindir}/bech32#{exe} --version"
      { 'cardano-node' => cn,
        'cardano-cli' => cli,
        'cardano-wallet' => cw,
        'cardano-address' => ca,
        'bech32' => b32 }
    end
  end
end
