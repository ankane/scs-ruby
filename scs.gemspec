require_relative "lib/scs/version"

Gem::Specification.new do |spec|
  spec.name          = "scs"
  spec.version       = SCS::VERSION
  spec.summary       = "SCS - the splitting conic solver - for Ruby"
  spec.homepage      = "https://github.com/ankane/scs-ruby"
  spec.license       = "MIT"

  spec.author        = "Andrew Kane"
  spec.email         = "andrew@ankane.org"

  spec.files         = Dir["*.{md,txt}", "{ext,lib}/**/*", "vendor/scs/*", "vendor/scs/{include,linsys,src,test}/**/*"]
  spec.require_path  = "lib"
  spec.extensions    = ["ext/scs/extconf.rb"]

  spec.required_ruby_version = ">= 2.4"
end
