# frozen_string_literal: true

RSpec.describe 'Integration', :e2e, :integration do
  before(:each) do
    CardanoUp.base_dir = Dir.mktmpdir
    CardanoUp.cardano_up_config = File.join(CardanoUp.base_dir,
                                            '.cardano-test.json')
    CardanoUp.configure_default

    @env = 'preprod'
    @port = '7788'

    # Get configs and bins and start node and wallet
    CardanoUp::Install.install_configs(@env)
    CardanoUp::Install.install_bins('latest')
  end

  after(:each) do
    CardanoUp.remove_configuration
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

  it 'I can start_node_and_wallet and then stop_node_and_wallet' do
    bin_dir = CardanoUp.config['bin_dir']
    # Start node and wallet
    config = CardanoUp::Start.prepare_configuration({ env: @env, wallet_port: @port })
    started = CardanoUp::Start.start_node_and_wallet(config)

    assert_node_up(bin_dir, started[:node][:socket_path], started[:node][:protocol_magic])
    assert_wallet_connected(bin_dir, started[:wallet][:port])

    # Stop node and wallet
    CardanoUp::Start.stop_node_and_wallet(@env)
    assert_node_down(bin_dir, started[:node][:socket_path], started[:node][:protocol_magic])
    assert_wallet_disconnected(bin_dir, started[:wallet][:port])
  end

  it 'I can start_node_and_wallet and then stop_node and stop_wallet' do
    bin_dir = CardanoUp.config['bin_dir']
    # Start node and wallet
    config = CardanoUp::Start.prepare_configuration({ env: @env, wallet_port: @port })
    started = CardanoUp::Start.start_node_and_wallet(config)

    assert_node_up(bin_dir, started[:node][:socket_path], started[:node][:protocol_magic])
    assert_wallet_connected(bin_dir, started[:wallet][:port])

    # Stop node and wallet
    CardanoUp::Start.stop_node(@env)
    assert_node_down(bin_dir, started[:node][:socket_path], started[:node][:protocol_magic])

    CardanoUp::Start.stop_wallet(@env)
    assert_wallet_disconnected(bin_dir, started[:wallet][:port])
  end

  it 'I can start_node_and_wallet and then stop_wallet and stop_node' do
    bin_dir = CardanoUp.config['bin_dir']
    # Start node and wallet
    config = CardanoUp::Start.prepare_configuration({ env: @env, wallet_port: @port })
    started = CardanoUp::Start.start_node_and_wallet(config)

    assert_node_up(bin_dir, started[:node][:socket_path], started[:node][:protocol_magic])
    assert_wallet_connected(bin_dir, started[:wallet][:port])

    # Stop node and wallet
    CardanoUp::Start.stop_wallet(@env)
    assert_wallet_disconnected(bin_dir, started[:wallet][:port])

    CardanoUp::Start.stop_node(@env)
    assert_node_down(bin_dir, started[:node][:socket_path], started[:node][:protocol_magic])
  end

  it 'I can start_node and then stop_node' do
    bin_dir = CardanoUp.config['bin_dir']
    # Start node
    config = CardanoUp::Start.prepare_configuration({ env: @env, wallet_port: @port })
    started = CardanoUp::Start.start_node(config)
    assert_node_up(bin_dir, started[:node][:socket_path], started[:node][:protocol_magic])

    # Stop node
    CardanoUp::Start.stop_node(@env)
    assert_node_down(bin_dir, started[:node][:socket_path], started[:node][:protocol_magic])
  end

  it 'I can start_wallet and start_node then stop_node and stop_wallet' do
    bin_dir = CardanoUp.config['bin_dir']
    # Start start_wallet start_node
    config = CardanoUp::Start.prepare_configuration({ env: @env, wallet_port: @port })
    w = CardanoUp::Start.start_wallet(config)
    n = CardanoUp::Start.start_node(config)
    assert_node_up(bin_dir, n[:node][:socket_path], n[:node][:protocol_magic])
    assert_wallet_connected(bin_dir, w[:wallet][:port])

    # stop_node stop_wallet
    CardanoUp::Start.stop_node(@env)
    CardanoUp::Start.stop_wallet(@env)
    assert_node_down(bin_dir, n[:node][:socket_path], n[:node][:protocol_magic])
    assert_wallet_disconnected(bin_dir, w[:wallet][:port])
  end

  it 'I can start_wallet and start_node then stop_wallet and stop_node' do
    bin_dir = CardanoUp.config['bin_dir']
    # Start start_wallet start_node
    config = CardanoUp::Start.prepare_configuration({ env: @env, wallet_port: @port })
    w = CardanoUp::Start.start_wallet(config)
    n = CardanoUp::Start.start_node(config)
    assert_node_up(bin_dir, n[:node][:socket_path], n[:node][:protocol_magic])
    assert_wallet_connected(bin_dir, w[:wallet][:port])

    # stop_node stop_wallet
    CardanoUp::Start.stop_wallet(@env)
    CardanoUp::Start.stop_node(@env)
    assert_node_down(bin_dir, n[:node][:socket_path], n[:node][:protocol_magic])
    assert_wallet_disconnected(bin_dir, w[:wallet][:port])
  end
end
