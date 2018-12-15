# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'eager_group/version'

Gem::Specification.new do |spec|
  spec.name          = "eager_group"
  spec.version       = EagerGroup::VERSION
  spec.authors       = ["Richard Huang"]
  spec.email         = ["flyerhzm@gmail.com"]

  spec.summary       = %q{Fix n+1 aggregate sql functions}
  spec.description   = %q{Fix n+1 aggregate sql functions for rails}
  spec.homepage      = "https://github.com/xinminlabs/eager_group"

  spec.license = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.3"
  spec.add_development_dependency "sqlite3", "~> 1.3"
  spec.add_development_dependency "activerecord"
  spec.add_development_dependency "activerecord-import"
  spec.add_development_dependency "benchmark-ips"
end
