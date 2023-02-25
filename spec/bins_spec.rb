# frozen_string_literal: true

RSpec.describe CardanoUp::Bins do
  before(:each) do
    set_cardano_up_config
  end

  after(:each) do
    CardanoUp.remove_cardano_up_config
  end

  %w[latest v2022-12-14].each do |release|
    it "can install bins from #{release}" do
      c = CardanoUp.config
      bin_dir = c[:bin_dir]
      expect(Dir["#{bin_dir}/*"].size).to eq 0

      bins = CardanoUp::Bins.install(release)
      expect(bins).to include('cardano-wallet', 'cardano-node',
                              'cardano-cli', 'cardano-address',
                              'bech32')
      expect(Dir["#{bin_dir}/*"].join(',')).to include('cardano-wallet', 'cardano-node',
                                                       'cardano-cli', 'cardano-address',
                                                       'bech32')
      expect(CardanoUp::Bins.return_versions).to eq bins
    end
  end

  it 'raise on install bins when not supported version' do
    ['master', '1234', 'latest release'].each do |release|
      expect do
        CardanoUp::Bins.install(release)
      end.to raise_error CardanoUp::VersionNotSupportedError,
                         /Not supported version/
    end
  end

  it 'raise on return_versions when bins not exist' do
    Dir.mktmpdir do |dir|
      CardanoUp.base_dir = dir
      CardanoUp.cardano_up_config = File.join(dir,
                                              'adrestia-bundler-test.json')
      CardanoUp.configure_default
      expect do
        CardanoUp::Bins.return_versions
      end.to raise_error StandardError, /No such file or directory/
    end
  end
end
