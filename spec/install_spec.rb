RSpec.describe AdrestiaBundler::Install do

  before(:all) do
    AdrestiaBundler.base_dir = Dir.mktmpdir
    AdrestiaBundler.adrestia_bundler_config = File.join(AdrestiaBundler.base_dir,
                                                        'adrestia-bundler-test.json')
    AdrestiaBundler.configure_default
  end

  after(:all) do
    AdrestiaBundler.remove_configuration
  end

  it "can get_configs for environment" do
    env = 'preview'
    c_num = AdrestiaBundler::CONFIG_FILES.size
    c = AdrestiaBundler.get_config
    conf_dir = File.join(c['config_dir'], env)
    expect(Dir["#{conf_dir}/*"].size).to eq 0

    configs = AdrestiaBundler::Install.install_configs(env)
    expect(Dir["#{conf_dir}/*"].size).to eq c_num
    expect(Dir["#{conf_dir}/*"].size).to eq configs.size
  end

  it "raise on get_configs when not supported environment" do
    env = 'previeww'
    expect do
      AdrestiaBundler::Install.install_configs(env)
    end.to raise_error AdrestiaBundler::EnvNotSupportedError, /not supported/
  end

  it "can install_bins from master" do
    release = 'master'
    c = AdrestiaBundler.get_config
    bin_dir = c['bin_dir']
    expect(Dir["#{bin_dir}/*"].size).to eq 0

    bins = AdrestiaBundler::Install.install_bins(release)
    expect(bins).to include('cardano-wallet', 'cardano-node',
                                           'cardano-cli', 'cardano-address',
                                           'bech32')
    expect(Dir["#{bin_dir}/*"].join(',')).to include('cardano-wallet', 'cardano-node',
                                           'cardano-cli', 'cardano-address',
                                           'bech32')
    expect(AdrestiaBundler::Install.return_versions).to eq bins
  end

  it "raise on install_bins when not supported version" do
    release = 'latest release'
    expect do
      AdrestiaBundler::Install.install_bins(release)
    end.to raise_error AdrestiaBundler::VersionNotSupportedError,
                      /Not supported version/
  end

  it "raise on return_versions when bins not exist" do
    Dir.mktmpdir do |dir|
      AdrestiaBundler.base_dir = dir
      AdrestiaBundler.adrestia_bundler_config = File.join(dir,
                                                          'adrestia-bundler-test.json')
      AdrestiaBundler.configure_default
      expect do
        AdrestiaBundler::Install.return_versions
      end.to raise_error StandardError, /No such file or directory/
    end
  end

end
