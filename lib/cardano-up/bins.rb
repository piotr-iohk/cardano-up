# frozen_string_literal: true

module CardanoUp
  # Installing binaries for Cardano
  module Bins
    # Get cardano-wallet bundle binaries to your computer.
    # @param release [String] - 'latest' | /^v20.{2}-.{2}-.{2}/ | 'master' | '3341'
    # @raise CardanoUp::VersionNotSupportedError
    def self.install(release)
      CardanoUp.configure_default unless CardanoUp.configured?
      configs = CardanoUp.config
      url = CardanoUp::Utils.get_binary_url(release)
      bin_dir_env = FileUtils.mkdir_p(configs['bin_dir']).first
      file_to_unpack = File.join(bin_dir_env, 'binary-dist')
      CardanoUp::Utils.wget(url, file_to_unpack)

      unpack_binary(file_to_unpack, bin_dir_env)
      return_versions(bin_dir_env)
    end

    # Return versions of installed components
    # @raise CardanoUp::ConfigNotSetError
    def self.return_versions(bin_dir = nil)
      bindir = bin_dir.nil? ? CardanoUp.config['bin_dir'] : bin_dir
      exe = CardanoUp::Utils.win? ? '.exe' : ''
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

    def unpack_binary(file_path, destination)
      if CardanoUp::Utils.win?
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
  end
end
