# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-babushka/version'

Gem::Specification.new do |gem|
  gem.name          = "vagrant-babushka"
  gem.version       = VagrantPlugins::Babushka::VERSION
  gem.platform      = Gem::Platform::RUBY
  gem.authors       = ["Vladimir Valgis"]
  gem.email         = ["vladimir.valgis@gmail.com"]
  gem.description   = "A Vagrant plugin which allows virtual machines to be provisioned using Babushka."
  gem.summary       = "A Babushka provisioner for Vagrant"
  gem.homepage      = "https://github.com/vvalgis/vagrant-babushka"
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
