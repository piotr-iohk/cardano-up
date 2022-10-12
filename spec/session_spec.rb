# frozen_string_literal: true

RSpec.describe CardanoUp::Session do
  before(:all) do
    set_cardano_up_config
  end

  after(:all) do
    CardanoUp.remove_cardano_up_config
  end

  after(:each) do
    CardanoUp::Session.destroy_all!
  end

  it 'create and destroy empty' do
    session_name = 'test'
    expect(CardanoUp::Session.exists?(session_name)).to eq false
    CardanoUp::Session.create_or_update(session_name, { network: 'preprod' })
    expect(CardanoUp::Session.exists?(session_name)).to eq true
    CardanoUp::Session.destroy!(session_name)
    expect(CardanoUp::Session.exists?(session_name)).to eq false
  end

  it 'create -> update -> remove until session empty' do
    session_name = 'test2'

    session_details1 = { network: 'preprod', node: {} }
    session1 = { preprod: { network: 'preprod', node: {} } }

    session_details2 = { network: 'preprod', wallet: {} }
    session2 = { preprod: { network: 'preprod', node: {}, wallet: {} } }

    session_details3 = { network: 'mainnet', wallet: {}, node: {} }
    session3 = { preprod: { network: 'preprod', node: {}, wallet: {} },
                 mainnet: { network: 'mainnet', node: {}, wallet: {} } }

    session_rem4 = { network: 'mainnet', service: 'node' }
    session4 = { preprod: { network: 'preprod', node: {}, wallet: {} },
                 mainnet: { network: 'mainnet', wallet: {} } }

    session_rem5 = { network: 'mainnet', service: 'wallet' }
    session5 = { preprod: { network: 'preprod', node: {}, wallet: {} } }

    session_rem6 = { network: 'preprod', service: 'wallet' }
    session6 = { preprod: { network: 'preprod', node: {} } }

    session_rem7 = { network: 'preprod', service: 'node' }

    expect(CardanoUp::Session.exists?(session_name)).to eq false

    CardanoUp::Session.create_or_update(session_name, session_details1)
    expect(CardanoUp::Session.get(session_name)).to eq session1

    CardanoUp::Session.create_or_update(session_name, session_details2)
    expect(CardanoUp::Session.get(session_name)).to eq session2

    CardanoUp::Session.create_or_update(session_name, session_details3)
    expect(CardanoUp::Session.get(session_name)).to eq session3
    expect(CardanoUp::Session.exists?(session_name)).to eq true

    CardanoUp::Session.remove(session_name, session_rem4)
    expect(CardanoUp::Session.get(session_name)).to eq session4

    CardanoUp::Session.remove(session_name, session_rem5)
    expect(CardanoUp::Session.get(session_name)).to eq session5

    CardanoUp::Session.remove(session_name, session_rem6)
    expect(CardanoUp::Session.get(session_name)).to eq session6

    CardanoUp::Session.remove(session_name, session_rem7)
    expect(CardanoUp::Session.exists?(session_name)).to eq false
  end

  it 'raises ArgumentError when service_details not Hash' do
    session_name = 'test2'
    session_details1 = 'testing'
    expect do
      CardanoUp::Session.create_or_update(session_name, session_details1)
    end.to raise_error ArgumentError, /service_details should be Hash/
  end

  it 'raises ArgumentError when service_details has no network' do
    session_name = 'test2'
    session_details1 = {}
    expect do
      CardanoUp::Session.create_or_update(session_name, session_details1)
    end.to raise_error ArgumentError, /:network/
  end

  it 'raises SessionHasNodeError' do
    session_name = 'test2'

    session_details1 = { network: 'preprod', node: {} }
    session1 = { preprod: { network: 'preprod', node: {} } }

    expect(CardanoUp::Session.exists?(session_name)).to eq false

    CardanoUp::Session.create_or_update(session_name, session_details1)
    expect(CardanoUp::Session.get(session_name)).to eq session1

    expect do
      CardanoUp::Session.create_or_update(session_name, session_details1)
    end.to raise_error CardanoUp::SessionHasNodeError, /has node running/
  end

  it 'raises SessionHasWalletError' do
    session_name = 'test2'

    session_details1 = { network: 'preprod', wallet: {} }
    session1 = { preprod: { network: 'preprod', wallet: {} } }

    expect(CardanoUp::Session.exists?(session_name)).to eq false

    CardanoUp::Session.create_or_update(session_name, session_details1)
    expect(CardanoUp::Session.get(session_name)).to eq session1

    expect do
      CardanoUp::Session.create_or_update(session_name, session_details1)
    end.to raise_error CardanoUp::SessionHasWalletError, /has wallet running/
  end

  it 'create and remove what is not there' do
    session_name = 'test'
    session = { network: 'preprod', node: {} }
    session_created = { preprod: { network: 'preprod', node: {} } }
    expect(CardanoUp::Session.exists?(session_name)).to eq false
    CardanoUp::Session.create_or_update(session_name, session)
    expect(CardanoUp::Session.exists?(session_name)).to eq true
    expect(CardanoUp::Session.get(session_name)).to eq session_created

    session_rem1 = { network: 'mainnet', service: 'node' }
    CardanoUp::Session.remove(session_name, session_rem1)
    expect(CardanoUp::Session.get(session_name)).to eq session_created
    expect(CardanoUp::Session.exists?(session_name)).to eq true

    session_rem2 = { network: 'preprod', service: 'wallet' }
    CardanoUp::Session.remove(session_name, session_rem2)
    expect(CardanoUp::Session.get(session_name)).to eq session_created
    expect(CardanoUp::Session.exists?(session_name)).to eq true

    session_rem3 = { network: 'preprod', service: 'node' }
    CardanoUp::Session.remove(session_name, session_rem3)
    expect(CardanoUp::Session.exists?(session_name)).to eq false
  end
end
