module AdrestiaBundler
  module Install
    # Get all necessary config files for particular environment.
    # @param env [String] - one of {ENVS}
    # @raises AdrestiaBundler::EnvNotSupportedError
    def self.install_configs(env)
      AdrestiaBundler.configure_default unless AdrestiaBundler.configured?
      configs = AdrestiaBundler.get_config
      config_urls = AdrestiaBundler::Utils.get_config_urls(env)
      config_dir_env = FileUtils.mkdir_p(File.join(configs['config_dir'], env))
      config_urls.each do |url|
        AdrestiaBundler::Utils.wget(url, File.join(config_dir_env, File.basename(url)))
      end
    end

    # Get cardano-wallet bundle binaries to your computer.
    # @param release [String] - 'latest' | /^v20.{2}-.{2}-.{2}/ | 'master' | '3341'
    # @raises AdrestiaBundler::VersionNotSupportedError
    def self.install_bins(release)
      AdrestiaBundler.configure_default unless AdrestiaBundler.configured?
      configs = AdrestiaBundler.get_config
      url = AdrestiaBundler::Utils.get_binary_url(release)
      bin_dir_env = FileUtils.mkdir_p(configs['bin_dir']).first
      file_to_unpack = File.join(bin_dir_env, 'binary-dist')
      AdrestiaBundler::Utils.wget(url, file_to_unpack)

      unpack_binary(file_to_unpack, bin_dir_env)
      return_versions(bin_dir_env)
    end

    def unpack_binary(file_path, destination)
      if AdrestiaBundler::Utils.is_win?
        AdrestiaBundler::Tar.unzip(file_path, destination)
      else
        gio = AdrestiaBundler::Tar.ungzip(File.open(file_path, 'rb'))
        AdrestiaBundler::Tar.untar(gio, destination)
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
    # @raises AdrestiaBundler::ConfigNotSetError
    def self.return_versions(bin_dir = nil)
      bindir = bin_dir.nil? ? AdrestiaBundler.get_config['bin_dir'] : bin_dir
      exe = AdrestiaBundler::Utils.is_win? ? '.exe' : ''
      cn = AdrestiaBundler::Utils.cmd "#{bindir}/cardano-node#{exe} version"
      cli = AdrestiaBundler::Utils.cmd "#{bindir}/cardano-cli#{exe} version"
      cw = AdrestiaBundler::Utils.cmd "#{bindir}/cardano-wallet#{exe} version"
      ca = AdrestiaBundler::Utils.cmd "#{bindir}/cardano-address#{exe} version"
      b32 = AdrestiaBundler::Utils.cmd "#{bindir}/bech32#{exe} --version"
      { 'cardano-node' => cn,
        'cardano-cli' => cli,
        'cardano-wallet' => cw,
        'cardano-address' => ca,
        'bech32' => b32
      }
    end
  end
end
