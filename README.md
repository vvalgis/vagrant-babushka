# Vagrant Provisioner Babushka

A [Vagrant][1] plugin which allows virtual machines to be provisioned
using [Babushka][2].

Based on a [plugin concept][3] by @tcurdt.

[![Build Status](https://travis-ci.org/vvalgis/vagrant-babushka.png)](https://travis-ci.org/vvalgis/vagrant-babushka.png)  

[1]: <https://www.vagrantup.com>
[2]: <https://babushka.me>
[3]: <https://github.com/tcurdt/vagrant-boxes/blob/master/plugins/babushka_provisioner.rb>


## Requirements

* Vagrant 1.1+
* cURL on the virtual machine (will be installed if missing on Ubuntu)

Note: The latest version of this plugin has only been tested on Ubuntu
virtual machines. Please open a GitHub issue if it doesn't work for you
or your operating system.


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
  # ...or set the URL of the bootstrap script directly
  babushka.bootstrap_url = 'https://example.com/babushka-bootstrap'


  # Share a directory of local Babushka deps with the VM
  # This example shares the '.deps/' directory (relative to this
  # Vagrantfile) to '~/babushka-deps' on the guest machine (in the home
  # directory of the main SSH user on the guest)
  babushka.local_deps_path = '.deps'


  # Meet a local dep
  # Assuming a dep named 'htop' is defined in a file under './.deps'
  babushka.meet 'htop'

  # Meet a remote dep
  # Assuming source 'tcurdt' has a dep named 'rbenv system'
  babushka.meet 'rbenv system', :source => 'tcurdt'

  # Also, you can set values for deps' parameters
  babushka.meet 'rbenv system', :params => {:key => "value"}
  # ...and for remote deps:
  babushka.meet 'rbenv system', :source => 'tcurdt', :params => {:key => "value"}


  # Old, **DEPRECATED**, but working syntax

  # Meet a local dep
  # Assuming a dep named 'htop' is defined in a file under './.deps'
  babushka.local_dep 'htop'

  # Meet a remote dep
  # Assuming source 'tcurdt' has a dep named 'rbenv system'
  babushka.remote_dep 'tcurdt', 'rbenv system'

  # Also, you can set values for deps' parameters, using a hash as the last parameter
  babushka.remote_dep 'tcurdt', 'rbenv system', :path => '/opt/rbenv'


  # Set options for the Babushka run

  # Enable/disable colorised (ANSI) output from Babushka
  # The default value is inherited from Vagrant's current setting
  babushka.color = true

  # Enable Babushka's debug mode (defaults to false)
  babushka.debug = true

  # Only do a "dry run", don't meet any deps (defaults to false)
  babushka.dry_run = true

  # Show parameter values passed to deps (defaults to false)
  babushka.show_args = true

  # Enable silent mode, no output (defaults to false)
  babushka.silent = true

  # Enable/disable updating sources before running their deps (defaults to true)
  babushka.update = false

  # These options can be overridden on particular deps, for example:
  babushka.meet 'rbenv system', :source => 'tcurdt', :update => false
  babushka.meet 'htop', :color => false
end
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## Testing

1. `bundle install`
2. `bundle exec rspec`


## Thanks

[patcon](https://github.com/patcon)  
[wakeless](https://github.com/wakeless)  
[Val](https://github.com/Val)  
[bradfeehan](https://github.com/bradfeehan)  

## License

MIT
