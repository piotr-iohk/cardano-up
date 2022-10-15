# frozen_string_literal: true

RSpec.describe CardanoUp::Bins do
  before(:all) do
    set_cardano_up_config
  end

  after(:all) do
    CardanoUp.remove_cardano_up_config
  end

  it 'can install bins from master' do
    release = 'master'
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

  it 'raise on install bins when not supported version' do
    release = 'latest release'
    expect do
      CardanoUp::Bins.install(release)
    end.to raise_error CardanoUp::VersionNotSupportedError,
                       /Not supported version/
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
