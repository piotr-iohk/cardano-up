# frozen_string_literal: true

RSpec.describe CardanoUp::Launcher do
  before(:all) do
    CardanoUp.base_dir = Dir.mktmpdir
    CardanoUp.cardano_up_config = File.join(CardanoUp.base_dir,
                                            '.cardano-test.json')
    CardanoUp.configure_default
  end

  after(:all) do
    CardanoUp.remove_cardano_up_config
  end

  it 'raise on setup when no port' do
    expect do
      CardanoUp::Launcher.setup({ env: 'mainnet' })
    end.to raise_error CardanoUp::WalletPortError, /Wallet port is not set/
  end

  it 'raise on setup when env not set' do
    expect do
      CardanoUp::Launcher.setup({ wallet_port: '8090' })
    end.to raise_error CardanoUp::EnvNotSupportedError, /not supported/
  end

  it 'raise on node_down when wrong env' do
    expect do
      CardanoUp::Launcher.node_down('env')
    end.to raise_error CardanoUp::EnvNotSupportedError, /not supported/
  end

  it 'raise on wallet_down when wrong env' do
    expect do
      CardanoUp::Launcher.wallet_down('env')
    end.to raise_error CardanoUp::EnvNotSupportedError, /not supported/
  end
end
