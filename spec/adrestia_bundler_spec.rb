RSpec.describe AdrestiaBundler do
  it "has a version number" do
    expect(AdrestiaBundler::VERSION).not_to be nil
  end

  describe "Configuration" do
    before(:all) do
      AdrestiaBundler.base_dir = Dir.tmpdir
    end

    after(:each) do
      AdrestiaBundler.remove_configuration
    end

    it "can configure default" do
      expect(AdrestiaBundler.configured?).to eq false
      config = AdrestiaBundler.configure_default
      expect(AdrestiaBundler.configured?).to eq true
      config_got = AdrestiaBundler.get_config
      expect(config).to include('state_dir', 'log_dir', 'bin_dir', 'config_dir')
      expect(config).to eq config_got
    end

    it "can configure explicitly" do
      expect(AdrestiaBundler.configured?).to eq false
      config = AdrestiaBundler.configure('/bins', '/state', '/logs', '/configs')
      expect(AdrestiaBundler.configured?).to eq true
      config_got = AdrestiaBundler.get_config
      expect(config).to eq({'bin_dir' => '/bins', 'state_dir' => '/state',
                           'log_dir' => '/logs', 'config_dir' => '/configs'})
      expect(config).to eq config_got
    end

    it "raise error when not configured" do
      expect(AdrestiaBundler.configured?).to eq false
      expect{ AdrestiaBundler.get_config }.to raise_error AdrestiaBundler::ConfigNotSetError,
                                                           /Config not exists/
    end
  end

end
