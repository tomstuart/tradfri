lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tradfri/version'

Gem::Specification.new do |spec|
  spec.name          = 'tradfri'
  spec.version       = Tradfri::VERSION
  spec.author        = 'Tom Stuart'
  spec.email         = 'tom@codon.com'
  spec.summary       = 'A Ruby interface to IKEA’s smart lighting system'
  spec.homepage      = 'https://github.com/tomstuart/tradfri'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'dnssd', '~> 3.0', '>= 3.0.0'
end
