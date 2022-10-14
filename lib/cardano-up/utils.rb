# frozen_string_literal: true

module CardanoUp
  # Utility methods
  module Utils
    def self.cmd(cmd, display_result: false)
      cmd.gsub(/\s+/, ' ')
      res = `#{cmd}`
      puts cmd if display_result
      puts res if display_result
      res.gsub("\n", ' ').strip
    end

    def self.wget(url, file = nil)
      file ||= File.basename(url)
      resp = HTTParty.get(url)
      File.binwrite(file, resp.body)
    end

    # Check if port is already used
    def self.port_used?(port)
      begin
        Timeout.timeout(1) do
          s = TCPSocket.new('localhost', port)
          s.close
          return true
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
          return false
        end
      rescue Timeout::Error
        # do nothing
      end

      false
    end

    def self.from_json(file)
      JSON.parse(File.read(file), { symbolize_names: true })
    end

    def self.to_json(file, hash)
      File.write(file, JSON.pretty_generate(hash))
    end

    def self.win?
      RUBY_PLATFORM =~ /cygwin|mswin|mingw|bccwin|wince|emx/
    end

    def self.linux?
      RUBY_PLATFORM =~ /linux/
    end

    def self.mac?
      RUBY_PLATFORM =~ /darwin/
    end

    def self.latest_tag
      HTTParty.get("#{CardanoUp::BINS_BASE_URL}/releases/latest",
                   headers: { 'Accept' => 'application/json' })['tag_name']
    end

    ##
    # Latest binary url for latest release or particular tag, from master or pr num.
    # @param release [String] - 'latest' | /^v20.{2}-.{2}-.{2}/ | 'master' | '3341'
    # @raise CardanoUp::VersionNotSupportedError
    def self.get_binary_url(release = 'latest')
      unless release == 'master' || release == 'latest' || release =~ /^v20.{2}-.{2}-.{2}/ || release =~ /^\d+$/
        raise CardanoUp::VersionNotSupportedError, release
      end

      url = ''
      if release == 'latest' || release =~ /^v20.{2}-.{2}-.{2}/
        tag = release == 'latest' ? latest_tag : release
        if linux?
          file = "cardano-wallet-#{tag}-linux64.tar.gz"
        elsif mac?
          file = "cardano-wallet-#{tag}-macos-intel.tar.gz"
        elsif win?
          file = "cardano-wallet-#{tag}-win64.zip"
        end
        url = "#{CardanoUp::BINS_BASE_URL}/releases/download/#{tag}/#{file}"
      else
        if linux?
          os = 'linux.musl.cardano-wallet-linux64'
        elsif mac?
          os = 'macos.intel.cardano-wallet-macos-intel'
        elsif win?
          os = 'linux.windows.cardano-wallet-win64'
        end

        url = if release == 'master'
                "#{CardanoUp::HYDRA_BASE_URL}/#{os}/latest/download-by-type/file/binary-dist"
              else
                "#{CardanoUp::HYDRA_BASE_URL}-pr-#{release}/#{os}/latest/download-by-type/file/binary-dist"
              end
      end
      url
    end

    ##
    # Latest Cardano configs
    # @raise CardanoUp::EnvNotSupportedError
    def self.configs_base_url(env)
      raise CardanoUp::EnvNotSupportedError, env unless CardanoUp::ENVS.include?(env)

      "#{CardanoUp::CONFIGS_BASE_URL}/#{env}/"
    end

    # @raise CardanoUp::EnvNotSupportedError
    def self.config_urls(env)
      raise CardanoUp::EnvNotSupportedError, env unless CardanoUp::ENVS.include?(env)

      base_url = configs_base_url(env)
      configs = []
      CardanoUp::CONFIG_FILES.each do |file|
        configs << "#{base_url}#{file}"
      end
      configs
    end
  end
end
