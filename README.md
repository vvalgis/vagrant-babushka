# Vagrant Provisioner Babushka 

Based on plugin created by @tcurdt
https://github.com/tcurdt/vagrant-boxes/blob/master/plugins/babushka_provisioner.rb

## Installation

    $ vagrant plugin install vagrant-babushka

## Usage

In Vagrant file set provisioner to `:babushka`

    config.vm.provision :babushka do |b|
      # Path for local deps, relative to Vagrantfile.
      # Syncronized to '/home/vagrant/babushka-deps' on guest machine
      b.local_deps_path = '.deps' 
      # add local dep which is defined in '.deps/htop.rb' with name 'htop'
      b.local_dep 'htop'
      # add remote dep in source 'tcurdt' with name 'rbenv system'
      b.remote_dep 'tcurdt', 'rbenv system' 
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

MIT
