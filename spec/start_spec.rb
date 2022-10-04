RSpec.describe AdrestiaBundler::Start do

  before(:all) do
    AdrestiaBundler.base_dir = Dir.mktmpdir
    AdrestiaBundler.adrestia_bundler_config = File.join(AdrestiaBundler.base_dir,
                                                        'adrestia-bundler-test.json')
    AdrestiaBundler.configure_default
  end

  after(:all) do
    AdrestiaBundler.remove_configuration
  end

  it "raise on start_node_and_wallet when no port" do
    expect do
      AdrestiaBundler::Start.start_node_and_wallet({ env: 'mainnet' })
    end.to raise_error AdrestiaBundler::WalletPortError, /Wallet port is not set/
  end

  it "raise on start_node_and_wallet when env not set" do
    expect do
      AdrestiaBundler::Start.start_node_and_wallet({ wallet_port: '8090' })
    end.to raise_error AdrestiaBundler::EnvNotSupportedError, /not supported/
  end

  it "raise on stop_node_and_wallet when wrong env" do
    expect do
      AdrestiaBundler::Start.stop_node_and_wallet('env')
    end.to raise_error AdrestiaBundler::EnvNotSupportedError, /not supported/
  end

end
