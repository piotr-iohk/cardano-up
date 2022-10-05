RSpec.describe "Integration", :e2e, :integration do

  before(:all) do
    AdrestiaBundler.base_dir = Dir.mktmpdir
    AdrestiaBundler.adrestia_bundler_config = File.join(AdrestiaBundler.base_dir,
                                                        'adrestia-bundler-test.json')
    AdrestiaBundler.configure_default

    @env = 'preview'
    @port = '7788'

    # Get configs and bins and start node and wallet
    AdrestiaBundler::Install.install_configs(@env)
    AdrestiaBundler::Install.install_bins('latest')
  end

  after(:all) do
    AdrestiaBundler.remove_configuration
  end

  def assert_node_up(bin_dir, socket_path, protocol_magic)
    ENV['CARDANO_NODE_SOCKET_PATH'] = socket_path
    cli_cmd = "#{bin_dir}/cardano-cli query tip --testnet-magic #{protocol_magic}"
    eventually 'Node is up' do
      res_cli = AdrestiaBundler::Utils.cmd cli_cmd
      res_cli.include?('block')
    end
  end

  def assert_node_down(bin_dir, socket_path, protocol_magic)
    ENV['CARDANO_NODE_SOCKET_PATH'] = socket_path
    cli_cmd = "#{bin_dir}/cardano-cli query tip --testnet-magic #{protocol_magic}"
    eventually 'Node is down' do
      res_cli = AdrestiaBundler::Utils.cmd cli_cmd
      !res_cli.include?('block')
    end
  end

  def assert_wallet_connected(bin_dir, wallet_port)
    wal_cmd = "#{bin_dir}/cardano-wallet network information --port #{wallet_port}"
    eventually 'Wallet is up and connected' do
      res_wal = AdrestiaBundler::Utils.cmd wal_cmd
      res_wal.include?('network_info')
    end
  end

  def assert_wallet_disconnected(bin_dir, wallet_port)
    wal_cmd = "#{bin_dir}/cardano-wallet network information --port #{wallet_port}"
    eventually 'Wallet is disconnected' do
      res_wal = AdrestiaBundler::Utils.cmd wal_cmd
      !res_wal.include?('network_info')
    end
  end

  it "I can start_node_and_wallet and then stop_node_and_wallet" do
    bin_dir = AdrestiaBundler.get_config['bin_dir']
    # Start node and wallet
    config = AdrestiaBundler::Start.prepare_configuration({ env: @env, wallet_port: @port })
    started = AdrestiaBundler::Start.start_node_and_wallet(config)

    assert_node_up(bin_dir, started[:node][:socket_path], started[:node][:protocol_magic])
    assert_wallet_connected(bin_dir, started[:wallet][:port])

    # Stop node and wallet
    AdrestiaBundler::Start.stop_node_and_wallet(@env)
    assert_node_down(bin_dir, started[:node][:socket_path], started[:node][:protocol_magic])
    assert_wallet_disconnected(bin_dir, started[:wallet][:port])
  end

  it "I can start_node_and_wallet and then stop_node and stop_wallet" do
    bin_dir = AdrestiaBundler.get_config['bin_dir']
    # Start node and wallet
    config = AdrestiaBundler::Start.prepare_configuration({ env: @env, wallet_port: @port })
    started = AdrestiaBundler::Start.start_node_and_wallet(config)

    assert_node_up(bin_dir, started[:node][:socket_path], started[:node][:protocol_magic])
    assert_wallet_connected(bin_dir, started[:wallet][:port])

    # Stop node and wallet
    AdrestiaBundler::Start.stop_node(@env)
    assert_node_down(bin_dir, started[:node][:socket_path], started[:node][:protocol_magic])

    AdrestiaBundler::Start.stop_wallet(@env)
    assert_wallet_disconnected(bin_dir, started[:wallet][:port])
  end

  it "I can start_node_and_wallet and then stop_wallet and stop_node" do
    bin_dir = AdrestiaBundler.get_config['bin_dir']
    # Start node and wallet
    config = AdrestiaBundler::Start.prepare_configuration({ env: @env, wallet_port: @port })
    started = AdrestiaBundler::Start.start_node_and_wallet(config)

    assert_node_up(bin_dir, started[:node][:socket_path], started[:node][:protocol_magic])
    assert_wallet_connected(bin_dir, started[:wallet][:port])

    # Stop node and wallet
    AdrestiaBundler::Start.stop_wallet(@env)
    assert_wallet_disconnected(bin_dir, started[:wallet][:port])

    AdrestiaBundler::Start.stop_node(@env)
    assert_node_down(bin_dir, started[:node][:socket_path], started[:node][:protocol_magic])
  end

  it "I can start_node and then stop_node" do
    bin_dir = AdrestiaBundler.get_config['bin_dir']
    # Start node
    config = AdrestiaBundler::Start.prepare_configuration({ env: @env, wallet_port: @port })
    started = AdrestiaBundler::Start.start_node(config)
    assert_node_up(bin_dir, started[:node][:socket_path], started[:node][:protocol_magic])

    # Stop node
    AdrestiaBundler::Start.stop_node(@env)
    assert_node_down(bin_dir, started[:node][:socket_path], started[:node][:protocol_magic])
  end

  it "I can start_wallet and start_node then stop_node and stop_wallet" do
    bin_dir = AdrestiaBundler.get_config['bin_dir']
    # Start start_wallet start_node
    config = AdrestiaBundler::Start.prepare_configuration({ env: @env, wallet_port: @port })
    w = AdrestiaBundler::Start.start_wallet(config)
    n = AdrestiaBundler::Start.start_node(config)
    assert_node_up(bin_dir, n[:node][:socket_path], n[:node][:protocol_magic])
    assert_wallet_connected(bin_dir, w[:wallet][:port])

    # stop_node stop_wallet
    AdrestiaBundler::Start.stop_node(@env)
    AdrestiaBundler::Start.stop_wallet(@env)
    assert_node_down(bin_dir, n[:node][:socket_path], n[:node][:protocol_magic])
    assert_wallet_disconnected(bin_dir, w[:wallet][:port])
  end

  it "I can start_wallet and start_node then stop_wallet and stop_node" do
    bin_dir = AdrestiaBundler.get_config['bin_dir']
    # Start start_wallet start_node
    config = AdrestiaBundler::Start.prepare_configuration({ env: @env, wallet_port: @port })
    w = AdrestiaBundler::Start.start_wallet(config)
    n = AdrestiaBundler::Start.start_node(config)
    assert_node_up(bin_dir, n[:node][:socket_path], n[:node][:protocol_magic])
    assert_wallet_connected(bin_dir, w[:wallet][:port])

    # stop_node stop_wallet
    AdrestiaBundler::Start.stop_wallet(@env)
    AdrestiaBundler::Start.stop_node(@env)
    assert_node_down(bin_dir, n[:node][:socket_path], n[:node][:protocol_magic])
    assert_wallet_disconnected(bin_dir, w[:wallet][:port])
  end

end
