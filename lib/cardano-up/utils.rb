module CardanoUp
  module Utils
    def self.cmd(cmd, display_result = false)
      cmd.gsub(/\s+/, ' ')
      res = `#{cmd}`
      puts cmd if display_result
      puts res if display_result
      res.gsub("\n", '')
    end

    def self.wget(url, file = nil)
      file ||= File.basename(url)
      resp = HTTParty.get(url)
      File.binwrite(file, resp.body)
    end

    def self.is_win?
      RUBY_PLATFORM =~ /cygwin|mswin|mingw|bccwin|wince|emx/
    end

    def self.is_linux?
      RUBY_PLATFORM =~ /linux/
    end

    def self.is_mac?
      RUBY_PLATFORM =~ /darwin/
    end

    def self.get_latest_tag
      HTTParty.get("#{CardanoUp::BINS_BASE_URL}/releases/latest",
                   headers: { 'Accept' => 'application/json' })['tag_name']
    end

    ##
    # Latest binary url for latest release or particular tag, from master or pr num.
    # @param release [String] - 'latest' | /^v20.{2}-.{2}-.{2}/ | 'master' | '3341'
    # @raises CardanoUp::VersionNotSupportedError
    def self.get_binary_url(release = 'latest')
      unless (release == 'master' || release == 'latest' || release =~ /^v20.{2}-.{2}-.{2}/ || release =~ /^\d+$/)
        raise CardanoUp::VersionNotSupportedError, release
      end
      url = ''
      if (release == 'latest' || release =~ /^v20.{2}-.{2}-.{2}/)
        tag = release == 'latest' ? get_latest_tag : release
        if is_linux?
          file = "cardano-wallet-#{tag}-linux64.tar.gz"
        elsif is_mac?
          file = "cardano-wallet-#{tag}-macos-intel.tar.gz"
        elsif is_win?
          file = "cardano-wallet-#{tag}-win64.zip"
        end
        url = "#{CardanoUp::BINS_BASE_URL}/releases/download/#{tag}/#{file}"
      else
        if is_linux?
          os = "linux.musl.cardano-wallet-linux64"
        elsif is_mac?
          os = "macos.intel.cardano-wallet-macos-intel"
        elsif is_win?
          os = "linux.windows.cardano-wallet-win64"
        end

        if (release == 'master')
          url = "#{CardanoUp::HYDRA_BASE_URL}/#{os}/latest/download-by-type/file/binary-dist"
        else
          url = "#{CardanoUp::HYDRA_BASE_URL}-pr-#{release}/#{os}/latest/download-by-type/file/binary-dist"
        end
      end
      url
    end

    ##
    # Latest Cardano configs
    # @raises CardanoUp::EnvNotSupportedError
    def self.get_configs_base_url(env)
      unless CardanoUp::ENVS.include?(env)
        raise CardanoUp::EnvNotSupportedError.new(env)
      else
        "#{CardanoUp::CONFIGS_BASE_URL}/#{env}/"
      end
    end

    # @raises CardanoUp::EnvNotSupportedError
    def self.get_config_urls(env)
      unless CardanoUp::ENVS.include?(env)
        raise CardanoUp::EnvNotSupportedError.new(env)
      else
        base_url = get_configs_base_url(env)
        configs = []
        CardanoUp::CONFIG_FILES.each do |file|
          configs << "#{base_url}#{file}"
        end
      end
      configs
    end
  end
end
