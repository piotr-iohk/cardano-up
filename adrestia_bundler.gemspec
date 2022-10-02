require_relative 'lib/adrestia_bundler/version'

Gem::Specification.new do |spec|
  spec.name          = "adrestia_bundler"
  spec.version       = AdrestiaBundler::VERSION
  spec.authors       = ["Piotr Stachyra"]
  spec.email         = ["piotr.stachyra@gmail.com"]

  spec.summary       = 'Get latest Cardano Adrestia tools bundle on your system in no time!'
  spec.description   = 'Adrestia Bundler lets you get all essential Cardano Adrestia
                          tools on your system. Fire `adrestia-bundle install` and get latest: cardano-node,
                          cardano-cli, cardano-wallet, cardano-addresses and bech32 with all essential configs.
                          Then just fire `adrestia-bundle mainnet start` to start node and wallet servers.'
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
  spec.executables   = ['adrestia-bundle']
  spec.require_paths = ["lib", "bin"]

  spec.add_runtime_dependency 'httparty', '~> 0.18.0'

  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'rspec', '~> 3.7'
  spec.add_development_dependency 'rubocop', '~> 1.11'
end
