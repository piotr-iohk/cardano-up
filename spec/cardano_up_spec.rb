# frozen_string_literal: true

RSpec.describe CardanoUp do
  it 'has a version number' do
    expect(CardanoUp::VERSION).not_to be nil
  end

  describe 'Configuration' do
    before(:all) do
      CardanoUp.base_dir = Dir.mktmpdir
      CardanoUp.adrestia_bundler_config = File.join(CardanoUp.base_dir,
                                                    'adrestia-bundler-test.json')
    end

    after(:each) do
      CardanoUp.remove_configuration
    end

    it 'can configure default' do
      expect(CardanoUp.configured?).to eq false
      config = CardanoUp.configure_default
      expect(CardanoUp.configured?).to eq true
      config_got = CardanoUp.get_config
      expect(config).to include('state_dir', 'log_dir', 'bin_dir', 'config_dir')
      expect(config).to eq config_got
    end

    it 'can configure explicitly' do
      expect(CardanoUp.configured?).to eq false
      config = CardanoUp.configure('/bins', '/state', '/logs', '/configs')
      expect(CardanoUp.configured?).to eq true
      config_got = CardanoUp.get_config
      expect(config).to eq({ 'bin_dir' => '/bins', 'state_dir' => '/state',
                             'log_dir' => '/logs', 'config_dir' => '/configs' })
      expect(config).to eq config_got
    end

    it 'raise error when not configured' do
      expect(CardanoUp.configured?).to eq false
      expect { CardanoUp.get_config }.to raise_error CardanoUp::ConfigNotSetError,
                                                     /Config not exists/
    end
  end
end
