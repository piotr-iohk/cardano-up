RSpec.describe CardanoUp::Install do

  before(:all) do
    CardanoUp.base_dir = Dir.mktmpdir
    CardanoUp.adrestia_bundler_config = File.join(CardanoUp.base_dir,
                                                        'adrestia-bundler-test.json')
    CardanoUp.configure_default
  end

  after(:all) do
    CardanoUp.remove_configuration
  end

  it "can get_configs for environment" do
    env = 'preview'
    c_num = CardanoUp::CONFIG_FILES.size
    c = CardanoUp.get_config
    conf_dir = File.join(c['config_dir'], env)
    expect(Dir["#{conf_dir}/*"].size).to eq 0

    configs = CardanoUp::Install.install_configs(env)
    expect(Dir["#{conf_dir}/*"].size).to eq c_num
    expect(Dir["#{conf_dir}/*"].size).to eq configs.size
  end

  it "raise on get_configs when not supported environment" do
    env = 'previeww'
    expect do
      CardanoUp::Install.install_configs(env)
    end.to raise_error CardanoUp::EnvNotSupportedError, /not supported/
  end

  it "can install_bins from master" do
    release = 'master'
    c = CardanoUp.get_config
    bin_dir = c['bin_dir']
    expect(Dir["#{bin_dir}/*"].size).to eq 0

    bins = CardanoUp::Install.install_bins(release)
    expect(bins).to include('cardano-wallet', 'cardano-node',
                                           'cardano-cli', 'cardano-address',
                                           'bech32')
    expect(Dir["#{bin_dir}/*"].join(',')).to include('cardano-wallet', 'cardano-node',
                                           'cardano-cli', 'cardano-address',
                                           'bech32')
    expect(CardanoUp::Install.return_versions).to eq bins
  end

  it "raise on install_bins when not supported version" do
    release = 'latest release'
    expect do
      CardanoUp::Install.install_bins(release)
    end.to raise_error CardanoUp::VersionNotSupportedError,
                      /Not supported version/
  end

  it "raise on return_versions when bins not exist" do
    Dir.mktmpdir do |dir|
      CardanoUp.base_dir = dir
      CardanoUp.adrestia_bundler_config = File.join(dir,
                                                          'adrestia-bundler-test.json')
      CardanoUp.configure_default
      expect do
        CardanoUp::Install.return_versions
      end.to raise_error StandardError, /No such file or directory/
    end
  end

end
