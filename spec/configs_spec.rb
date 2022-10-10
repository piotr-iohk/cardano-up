# frozen_string_literal: true

RSpec.describe CardanoUp::Configs do
  before(:all) do
    set_cardano_up_config
  end

  after(:all) do
    CardanoUp.remove_cardano_up_config
  end

  it 'can get configs for environment' do
    env = 'preview'
    expect(CardanoUp::Configs.exist?(env)).to be false
    CardanoUp::Configs.get(env)
    expect(CardanoUp::Configs.exist?(env)).to be true
  end

  it 'raise on exist? when not supported environment' do
    env = 'previeww'
    expect do
      CardanoUp::Configs.exist?(env)
    end.to raise_error CardanoUp::EnvNotSupportedError, /not supported/
  end

  it 'raise on get configs when not supported environment' do
    env = 'previeww'
    expect do
      CardanoUp::Configs.get(env)
    end.to raise_error CardanoUp::EnvNotSupportedError, /not supported/
  end
end
