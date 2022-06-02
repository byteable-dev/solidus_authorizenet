require_relative "lib/solidus_authorizenet/version"

Gem::Specification.new do |spec|
  spec.name        = "solidus_authorizenet"
  spec.version     = SolidusAuthorizenet::VERSION
  spec.authors     = ["Rasmus Styrk"]
  spec.email       = ["styrken@gmail.com"]
  spec.homepage    = "https://github.com/byteable-dev/solidus_authorizenet"
  spec.summary     = "A payment solution for solidus that uses authorize.net"
  spec.description = "A payment solution for solidus that uses authorize.net"
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/byteable-dev/solidus_authorizenet"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 6.1.6"
end
