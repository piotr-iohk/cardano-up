# frozen_string_literal: true

module CardanoUp
  # Check status (ping) of running node and wallet services
  module Ping
    # @param session_name [String]
    # @param env [String]
    # @raise CardanoUp::EnvNotSupportedError
    # @raise CardanoUp::SessionNotExistsError
    # @raise CardanoUp::SessionServiceNotUpError
    # @raise CardanoUp::SessionEnvNotUpError
    def self.wallet(session_name, env)
      CardanoUp::Configs.exist?(env)
      CardanoUp::Session.network_or_raise?(session_name, env.to_sym)
      CardanoUp::Session.wallet_or_raise?(session_name, env.to_sym)
      session = CardanoUp::Session.get(session_name)

      url = session[env.to_sym][:wallet][:url]
      r = HTTParty.get("#{url}/network/information")
      [r.parsed_response, r.code]
    end

    # @param session_name [String]
    # @param env [String]
    # @raise CardanoUp::EnvNotSupportedError
    # @raise CardanoUp::SessionNotExistsError
    # @raise CardanoUp::SessionServiceNotUpError
    # @raise CardanoUp::SessionEnvNotUpError
    def self.node(session_name, env)
      CardanoUp::Configs.exist?(env)
      CardanoUp::Session.network_or_raise?(session_name, env.to_sym)
      CardanoUp::Session.node_or_raise?(session_name, env.to_sym)
      session = CardanoUp::Session.get(session_name)
      bin_dir = CardanoUp.config[:bin_dir]

      ENV['CARDANO_NODE_SOCKET_PATH'] = session[env.to_sym][:node][:socket_path]
      protocol_magic = session[env.to_sym][:node][:protocol_magic]
      network_arg = env == 'mainnet' ? '--mainnet' : "--testnet-magic #{protocol_magic}"
      exe = CardanoUp::Utils.win? ? '.exe' : ''
      cmd = "#{File.join(bin_dir, 'cardano-cli')}#{exe} query tip #{network_arg}"
      CardanoUp::Utils.cmd cmd
    end
  end
end
