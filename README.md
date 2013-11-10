# Vagrant Provisioner Babushka

A [Vagrant][1] plugin which allows virtual machines to be provisioned
using [Babushka][2].

Based on a [plugin concept][3] by @tcurdt.

[1]: <https://www.vagrantup.com>
[2]: <https://babushka.me>
[3]: <https://github.com/tcurdt/vagrant-boxes/blob/master/plugins/babushka_provisioner.rb>


## Installation

```bash
vagrant plugin install vagrant-babushka
```


## Usage

Add a Babushka provision block to your project's Vagrantfile:

```ruby
config.vm.provision :babushka do |babushka|
  # Set the Git branch of Babushka to install on the guest (defaults to master)
  babushka.bootstrap_branch = 'master'

  # Share a directory of local Babushka deps with the VM
  # This example shares the '.deps/' directory (relative to this
  # Vagrantfile) to '~/babushka-deps' on the guest machine (in the home
  # directory of the main SSH user on the guest)
  babushka.local_deps_path = '.deps'

  # Meet a local dep
  # Assuming a dep named 'htop' is defined in a file under './.deps'
  babushka.local_dep 'htop'

  # Meet a remote dep
  # Assuming source 'tcurdt' has a dep named 'rbenv system'
  babushka.remote_dep 'tcurdt', 'rbenv system'

  # Also, you can set options for deps, using a hash as the third parameter
  babushka.remote_dep 'tcurdt', 'rbenv system', :path => '/opt/rbenv'
end
```


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
