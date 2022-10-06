RSpec.describe CardanoUp::Utils do
  it "I can cmd" do
    res = CardanoUp::Utils.cmd 'echo "I can echo"'
    expect(res).to eq "I can echo"
  end

  it "I can wget" do
    Dir.mktmpdir do |dir|
      test_file = File.join(dir, 'test.txt')
      CardanoUp::Utils.wget("https://google.com", test_file)
      expect(File).to exist(test_file)
    end
  end

  it "I can get_latest_tag" do
    tag = CardanoUp::Utils.get_latest_tag
    expect(tag).to start_with('v')
  end

  it "I can get_binary_url" do
    tag = CardanoUp::Utils.get_binary_url
    expect(tag).to include('https://github.com/input-output-hk/cardano-wallet/releases/download')

    tag = CardanoUp::Utils.get_binary_url('v2022-08-16')
    expect(tag).to include('https://github.com/input-output-hk/cardano-wallet/releases/download')

    tag = CardanoUp::Utils.get_binary_url('master')
    expect(tag).to include('https://hydra.iohk.io/job/Cardano/cardano-wallet/')

    tag = CardanoUp::Utils.get_binary_url('3045')
    expect(tag).to include('https://hydra.iohk.io/job/Cardano/cardano-wallet-pr-3045/')
  end

  it "I need get_binary_url with proper param" do
    expect { CardanoUp::Utils.get_binary_url('wrong') }.to raise_error CardanoUp::VersionNotSupportedError,
                                                                           /Not supported version/
  end

  it "I can get_configs_base_url" do
    CardanoUp::ENVS.each do |env|
      env_url = CardanoUp::Utils.get_configs_base_url(env)
      expect(env_url).to eq("https://book.world.dev.cardano.org/environments/#{env}/")
    end
  end

  it "I can't get_configs_base_url for config that is not supported" do
    expect do
      CardanoUp::Utils.get_configs_base_url('env')
    end.to raise_error CardanoUp::EnvNotSupportedError, /not supported/
  end

  it "I can get_config_urls" do
    CardanoUp::ENVS.each do |env|
      configs = CardanoUp::Utils.get_config_urls(env)
      expect(configs.size).to eq 5
    end
  end
end
