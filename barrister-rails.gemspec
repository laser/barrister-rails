# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'barrister-rails/version'

Gem::Specification.new do |spec|
  spec.name          = "barrister-rails"
  spec.version       = Barrister::Rails::VERSION
  spec.authors       = ["Erin Swenson-Healey"]
  spec.email         = ["erin.swenson.healey@gmail.com"]
  spec.summary       = %q{TODO: Write a short summary. Required.}
  spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "barrister", "~> 0"
  spec.add_dependency "active_attr", "~> 0"
  spec.add_development_dependency "pry", "~> 0"
end