# frozen_string_literal: true

RSpec.describe 'Integration', :e2e, :integration do
  before(:all) do
    set_cardano_up_config
    @env = 'preprod'
    @port = '7788'
    @session = 'i'
    CardanoUp::Bins.install('latest')
    CardanoUp::Configs.get(@env)
  end

  after(:each) do
    CardanoUp.clean_config_dir(:state_dir)
  end

  def assert_node_up(bin_dir, socket_path, protocol_magic)
    ENV['CARDANO_NODE_SOCKET_PATH'] = socket_path
    cli_cmd = "#{bin_dir}/cardano-cli query tip --testnet-magic #{protocol_magic}"
    eventually 'Node is up' do
      res_cli = CardanoUp::Utils.cmd cli_cmd
      puts res_cli
      res_cli.include?('block')
    end
  end

  def assert_node_down(bin_dir, socket_path, protocol_magic)
    ENV['CARDANO_NODE_SOCKET_PATH'] = socket_path
    cli_cmd = "#{bin_dir}/cardano-cli query tip --testnet-magic #{protocol_magic}"
    eventually 'Node is down' do
      res_cli = CardanoUp::Utils.cmd cli_cmd
      puts res_cli
      !res_cli.include?('block')
    end
  end

  def assert_wallet_connected(bin_dir, wallet_port)
    wal_cmd = "#{bin_dir}/cardano-wallet network information --port #{wallet_port}"
    eventually 'Wallet is up and connected' do
      res_wal = CardanoUp::Utils.cmd wal_cmd
      puts res_wal
      res_wal.include?('network_info')
    end
  end

  def assert_wallet_disconnected(bin_dir, wallet_port)
    wal_cmd = "#{bin_dir}/cardano-wallet network information --port #{wallet_port}"
    eventually 'Wallet is disconnected' do
      res_wal = CardanoUp::Utils.cmd wal_cmd
      puts res_wal
      !res_wal.include?('network_info')
    end
  end

  it 'I can do node_up and wallet_up and then node_down and wallet_down' do
    bin_dir = CardanoUp.config[:bin_dir]
    # Start node and wallet
    config = CardanoUp::Launcher.setup({ env: @env, wallet_port: @port, session_name: @session })
    node = CardanoUp::Launcher.node_up(config)
    wallet = CardanoUp::Launcher.wallet_up(config)
    expect(CardanoUp::Session.network_or_raise?(@session, @env)).to be true
    expect(CardanoUp::Session.node_or_raise?(@session, @env)).to be true
    expect(CardanoUp::Session.wallet_or_raise?(@session, @env)).to be true

    assert_node_up(bin_dir, node[:node][:socket_path], node[:node][:protocol_magic])
    assert_wallet_connected(bin_dir, wallet[:wallet][:port])
    expect(CardanoUp::Ping.wallet(@session, @env).last).to eq 200
    expect(CardanoUp::Ping.node(@session, @env).last).to eq 200

    # Stop node and wallet
    CardanoUp::Launcher.node_down(@env, @session)
    CardanoUp::Launcher.wallet_down(@env, @session)
    assert_node_down(bin_dir, node[:node][:socket_path], node[:node][:protocol_magic])
    assert_wallet_disconnected(bin_dir, wallet[:wallet][:port])
    expect(CardanoUp::Session.exists?(@session)).to be false
  end

  it 'I can node_up and then node_down' do
    bin_dir = CardanoUp.config[:bin_dir]
    # Start node
    config = CardanoUp::Launcher.setup({ env: @env, wallet_port: @port, session_name: @session })
    node = CardanoUp::Launcher.node_up(config)
    expect(CardanoUp::Session.network_or_raise?(@session, @env)).to be true
    expect(CardanoUp::Session.node_or_raise?(@session, @env)).to be true

    assert_node_up(bin_dir, node[:node][:socket_path], node[:node][:protocol_magic])
    expect(CardanoUp::Ping.node(@session, @env).last).to eq 200

    # Stop node
    CardanoUp::Launcher.node_down(@env, @session)
    assert_node_down(bin_dir, node[:node][:socket_path], node[:node][:protocol_magic])
    expect(CardanoUp::Session.exists?(@session)).to be false
  end

  it 'I can wallet_up and then wallet_down' do
    bin_dir = CardanoUp.config[:bin_dir]
    # Start wallet
    config = CardanoUp::Launcher.setup({ env: @env, wallet_port: @port, session_name: @session })
    wallet = CardanoUp::Launcher.wallet_up(config)
    expect(CardanoUp::Session.network_or_raise?(@session, @env)).to be true
    expect(CardanoUp::Session.wallet_or_raise?(@session, @env)).to be true

    # Stop wallet
    CardanoUp::Launcher.wallet_down(@env, @session)
    assert_wallet_disconnected(bin_dir, wallet[:wallet][:port])
    expect(CardanoUp::Session.exists?(@session)).to be false
  end
end
