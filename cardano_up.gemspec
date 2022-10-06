require_relative 'lib/cardano_up/version'

Gem::Specification.new do |spec|
  spec.name          = "cardano_up"
  spec.version       = CardanoUp::VERSION
  spec.authors       = ["Piotr Stachyra"]
  spec.email         = ["piotr.stachyra@gmail.com"]

  spec.summary       = 'Get latest Cardano Adrestia tools bundle on your system in no time!'
  spec.description   = 'Adrestia Bundler lets you get all essential Cardano Adrestia
                        tools on your system: cardano-node, cardano-cli, cardano-wallet,
                        cardano-addresses and bech32. Then easily start/stop cardano-node and
                        cardano-wallet with lean configuration.'
  spec.homepage      = 'https://github.com/piotr-iohk/adrestia-bundler'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.0")

  spec.metadata["allowed_push_host"] = 'https://rubygems.org/'

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  # spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
  #   `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  # end
  spec.files         = Dir["{bin,lib}/**/*", "LICENSE.txt", "README.md"]
  # spec.test_files    = Dir["spec/**/*"]
  spec.bindir        = "bin"
  # spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.executables   = ['cardano-up']
  spec.require_paths = ["lib", "bin"]

  spec.add_runtime_dependency 'httparty', '0.20.0'
  spec.add_runtime_dependency 'rubyzip', '2.3.2'
  spec.add_runtime_dependency 'docopt', '0.6.1'

  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'rspec', '~> 3.11'
  spec.add_development_dependency 'rubocop', '~> 1.11'
end
