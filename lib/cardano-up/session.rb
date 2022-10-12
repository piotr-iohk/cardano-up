# frozen_string_literal: true

module CardanoUp
  # Basic sessions management
  module Session
    # Check session file exists
    def self.exists?(session_name)
      CardanoUp.configure_default unless CardanoUp.configured?
      File.exist?(session_file_path(session_name))
    end

    # get session contents
    def self.get(session_name)
      CardanoUp.configure_default unless CardanoUp.configured?
      session = session_file_path(session_name)
      CardanoUp::Utils.from_json(session) if exists?(session_name)
    end

    def self.destroy!(session_name)
      path = session_file_path(session_name)
      FileUtils.rm_f(path)
    end

    def self.destroy_all!
      list_all.each do |path|
        FileUtils.rm_f(path)
      end
    end

    def self.list_all
      Dir[File.join(CardanoUp.base_dir, '.session*')]
    end

    # create or update session with details of launched service
    # @param [String] session name
    # @param [Hash] service details
    # @raise ArgumentError
    # @raise CardanoUp::SessionHasNodeError
    # @raise CardanoUp::SessionHasWalletError
    def self.create_or_update(session_name, service_details)
      raise ArgumentError, 'service_details should be Hash' unless service_details.is_a?(Hash)
      raise ArgumentError, 'service_details shoud have :network' if service_details[:network].nil?

      service_network = service_details[:network].to_sym || :unknown

      if !exists?(session_name) || empty?(session_name)
        # if session is not set then just create new with just service_details
        content = { service_network => service_details }
        put_content(session_name, content)
      elsif !network?(session_name, service_network)
        # if session exists but has no network, add new network
        existing_services = get(session_name)
        new_service = { service_network => service_details }
        put_content(session_name, existing_services.merge(new_service))
      elsif node?(session_name, service_network)
        # if session has network and node already, you can add only wallet
        raise CardanoUp::SessionHasNodeError.new(session_name, service_network) if service_details.key?(:node)

        existing_services = get(session_name)
        updated_network = existing_services[service_network].merge(service_details)
        existing_services[service_network] = updated_network
        put_content(session_name, existing_services)
      elsif wallet?(session_name, service_network)
        # if session has network and wallet already, you can add only node
        if service_details.key?(:wallet)
          raise CardanoUp::SessionHasWalletError.new(session_name,
                                                     service_network)
        end

        existing_services = get(session_name)
        updated_network = existing_services[service_network].merge(service_details)
        existing_services[service_network] = updated_network
        put_content(session_name, existing_services)
      end
    end

    # remove entry from session
    def self.remove(session_name, service_details)
      existing_services = get(session_name)
      service = service_details[:service].to_sym
      network = service_details[:network].to_sym
      if existing_services[network]
        existing_services[network].delete(service)

        unless existing_services[network].key?(:node) || existing_services[network].key?(:wallet)
          existing_services.delete(network)
        end
        put_content(session_name, existing_services)
      end

      destroy!(session_name) if empty?(session_name)
    end

    def session_file_path(session_name)
      File.join(CardanoUp.base_dir, ".session-#{session_name}.json")
    end
    module_function :session_file_path
    private_class_method :session_file_path

    def put_content(session_name, contents)
      raise ArgumentError, 'contents should be Hash' unless contents.is_a?(Hash)

      path = session_file_path(session_name)
      File.write(path, JSON.pretty_generate(contents))
      path
    end
    module_function :put_content
    private_class_method :put_content

    def empty?(session_name)
      get(session_name) == {}
    end
    module_function :empty?
    private_class_method :empty?

    def network?(session_name, env)
      get(session_name).key?(env.to_sym)
    end
    module_function :network?
    private_class_method :network?

    def node?(session_name, env)
      get(session_name)[env].key?(:node)
    end
    module_function :node?
    private_class_method :node?

    def wallet?(session_name, env)
      get(session_name)[env].key?(:wallet)
    end
    module_function :wallet?
    private_class_method :wallet?
  end
end
