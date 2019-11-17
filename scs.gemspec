require_relative "lib/scs/version"

Gem::Specification.new do |spec|
  spec.name          = "scs"
  spec.version       = SCS::VERSION
  spec.summary       = "SCS - the splitting conic solver - for Ruby"
  spec.homepage      = "https://github.com/ankane/scs"
  spec.license       = "MIT"

  spec.author        = "Andrew Kane"
  spec.email         = "andrew@chartkick.com"

  spec.files         = Dir["*.{md,txt}", "{ext,lib}/**/*", "vendor/scs/*", "vendor/scs/{include,linsys,src,test}/**/*"]
  spec.require_path  = "lib"
  spec.extensions    = ["ext/scs/Rakefile"]

  spec.required_ruby_version = ">= 2.4"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest", ">= 5"
  spec.add_development_dependency "numo-narray" unless ENV["APPVEYOR"]
end
