# Vagrant Provisioner Babushka

Based on plugin created by @tcurdt
https://github.com/tcurdt/vagrant-boxes/blob/master/plugins/babushka_provisioner.rb

## Installation

    $ vagrant plugin install vagrant-babushka

## Usage

In Vagrant file set provisioner to `:babushka`

    config.vm.provision :babushka do |b|
      # Uncoment to override default babushka branch on bootstrap
      # b.bootstrap_branch = 'master'
      # Path for local deps, relative to Vagrantfile.
      # Syncronized to '/home/ssh_user_name/babushka-deps' on guest machine.
      # 'ssh_user_name' here is 'vagrant' by default or any other name you use when connecting through ssh.
      b.local_deps_path = '.deps'
      # add local dep which is defined in '.deps/htop.rb' with name 'htop'
      b.local_dep 'htop'
      # add remote dep in source 'tcurdt' with name 'rbenv system'
      b.remote_dep 'tcurdt', 'rbenv system'
    end

Also you can add options to deps giving hash as third parameter

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Thanks
[patcon](https://github.com/patcon)
[wakeless](https://github.com/wakeless)
[Val](https://github.com/Val)

## License

MIT
