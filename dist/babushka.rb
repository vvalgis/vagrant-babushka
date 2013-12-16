#!/usr/bin/env ruby

# This is a modified version of the Babushka binary that is distributed
# with Babushka. It's been modified to ensure that stdout and stderr
# are automatically flushed when written to, and not buffered.
#
# When running inside Vagrant, this is more important than the
# performance gains associated with output buffering. This is because
# Babushka often prints messages like "installing..." during a long
# operation, and these usually aren't followed by a newline. So these
# types of messages will often sit in the buffer (unseen by the user)
# for the entire duration of the long operation. The user will only see
# the "installing" message after the next newline is printed, which
# will only happen when the installation is already complete!
$stdout.sync = true
$stderr.sync = true

# This file is what gets run when babushka is invoked from the command line.

# First, load babushka itself, by traversing from the actual location of
# this file (it might have been invoked via a symlink in the PATH) to the
# corresponding lib/babushka.rb.
require File.expand_path(
  File.join(
    File.dirname(File.expand_path(
      File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__
    )),
    '../lib/babushka'
  )
)

# Mix in the #Dep, #dep & #meta top-level helper methods, since we're running
# standalone.
Object.send :include, Babushka::DSL

# Handle ctrl-c gracefully during babushka runs.
Babushka::Base.exit_on_interrupt!

# Invoke babushka, returning the correct exit status to the shell.
exit !!Babushka::Base.run