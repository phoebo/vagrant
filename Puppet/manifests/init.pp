# Augeas: http://projects.puppetlabs.com/projects/1/wiki/puppet_augeas
# augtool print /augeas//error

# ------------------------------------------------------------------------------
# --- Basic setup
# ------------------------------------------------------------------------------

class { 'bootstrap': }

# ------------------------------------------------------------------------------
# Add your setup here

notify { 'my_message':
  message => hiera('my_message'),
}
