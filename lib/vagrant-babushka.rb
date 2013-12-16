begin
  require "vagrant"
rescue LoadError
  raise "vagrant-babushka must be loaded from within Vagrant."
end

I18n.load_path << File.expand_path("../../locales/en.yml", __FILE__)

require "vagrant-babushka/version"
require "vagrant-babushka/dep"
require "vagrant-babushka/config"
require "vagrant-babushka/provisioner"
require "vagrant-babushka/plugin"
