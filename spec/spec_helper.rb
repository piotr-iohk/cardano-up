# frozen_string_literal: true

require 'bundler/setup'
require 'cardano-up'
require 'tmpdir'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

TIMEOUT = 60

def set_cardano_up_config
  CardanoUp.base_dir = Dir.mktmpdir
  CardanoUp.cardano_up_config = File.join(CardanoUp.base_dir,
                                          '.cardano-test.json')
  CardanoUp.configure_default
end

def eventually(label, &block)
  current_time = Time.now
  timeout_treshold = current_time + TIMEOUT
  while (block.call == false) && (current_time <= timeout_treshold)
    sleep 5
    current_time = Time.now
  end
  raise "Action '#{label}' did not resolve within timeout: #{TIMEOUT}s" if current_time > timeout_treshold
end
