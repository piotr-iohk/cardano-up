RSpec.describe "Integration", :e2e, :integration do

  before(:all) do
    AdrestiaBundler.base_dir = Dir.mktmpdir
    AdrestiaBundler.adrestia_bundler_config = File.join(AdrestiaBundler.base_dir,
                                                        'adrestia-bundler-test.json')
    AdrestiaBundler.configure_default
  end

  after(:all) do
    AdrestiaBundler.remove_configuration
  end

  it "I can start and stop node and wallet" do
    release = 'latest'
    env = 'preview'
    port = '7788'

    # Get configs and bins and start node and wallet
    c = AdrestiaBundler::Install.install_configs(env)
    b = AdrestiaBundler::Install.install_bins(release)
    started = AdrestiaBundler::Start.start_node_and_wallet({env: env, wallet_port: port})

    bin_dir = AdrestiaBundler.get_config['bin_dir']
    ENV['CARDANO_NODE_SOCKET_PATH'] = started[:node][:socket_path]
    wal_cmd = "#{bin_dir}/cardano-wallet network information --port #{started[:wallet][:port]}"
    cli_cmd = "#{bin_dir}/cardano-cli query tip --testnet-magic #{started[:node][:protocol_magic]}"

    eventually 'Wallet and node are up and connected' do
      res_cli = AdrestiaBundler::Utils.cmd cli_cmd
      res_wal = AdrestiaBundler::Utils.cmd wal_cmd
      (res_wal.include?('network_info') && res_cli.include?('block'))
    end

    # Stop node and wallet
    AdrestiaBundler::Start.stop_node_and_wallet(env)
    eventually 'Wallet and node are down' do
      res_cli = AdrestiaBundler::Utils.cmd cli_cmd
      res_wal = AdrestiaBundler::Utils.cmd wal_cmd
      (!res_wal.include?('network_info') && !res_cli.include?('block'))
    end
  end

end
