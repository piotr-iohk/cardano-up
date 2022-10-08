# frozen_string_literal: true

RSpec.describe CardanoUp::Start do
  before(:all) do
    CardanoUp.base_dir = Dir.mktmpdir
    CardanoUp.cardano_up_config = File.join(CardanoUp.base_dir,
                                            '.cardano-test.json')
    CardanoUp.configure_default
  end

  after(:all) do
    CardanoUp.remove_cardano_up_config
  end

  it 'raise on prepare_configuration when no port' do
    expect do
      CardanoUp::Start.prepare_configuration({ env: 'mainnet' })
    end.to raise_error CardanoUp::WalletPortError, /Wallet port is not set/
  end

  it 'raise on prepare_configuration when env not set' do
    expect do
      CardanoUp::Start.prepare_configuration({ wallet_port: '8090' })
    end.to raise_error CardanoUp::EnvNotSupportedError, /not supported/
  end

  it 'raise on stop_node when wrong env' do
    expect do
      CardanoUp::Start.stop_node('env')
    end.to raise_error CardanoUp::EnvNotSupportedError, /not supported/
  end

  it 'raise on stop_wallet when wrong env' do
    expect do
      CardanoUp::Start.stop_wallet('env')
    end.to raise_error CardanoUp::EnvNotSupportedError, /not supported/
  end

  it 'raise on stop_node_and_wallet when wrong env' do
    expect do
      CardanoUp::Start.stop_node_and_wallet('env')
    end.to raise_error CardanoUp::EnvNotSupportedError, /not supported/
  end
end
