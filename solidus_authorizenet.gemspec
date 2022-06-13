require_relative "lib/solidus_authorizenet/version"

Gem::Specification.new do |spec|
  spec.name        = "solidus_authorizenet"
  spec.version     = SolidusAuthorizenet::VERSION
  spec.authors     = ["Rasmus Styrk"]
  spec.email       = ["styrken@gmail.com"]
  spec.homepage    = "https://github.com/byteable-dev/solidus_authorizenet"
  spec.summary     = "A payment solution for solidus that uses authorize.net"
  spec.description = spec.summary
  spec.license     = "BSD-3-Clause"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 6.1.6"

  spec.add_dependency 'authorizenet', '~> 2.0.1'
  spec.add_dependency 'activemerchant', '~> 1.48'
  spec.add_dependency 'solidus_core', ['>= 2.3', '< 4']
  spec.add_dependency 'solidus_support', '~> 0.8'

  spec.add_development_dependency 'solidus_dev_support', '~> 2.3'
end
