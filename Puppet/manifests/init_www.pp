# Augeas: http://projects.puppetlabs.com/projects/1/wiki/puppet_augeas
# augtool print /augeas//error

# ------------------------------------------------------------------------------
# --- Common setup
# ------------------------------------------------------------------------------

class { 'bootstrap': }
class { 'postgresql::server': }

package { 'redis-server':
	ensure => present
}

anchor { 'common::end':
	require => [
		Class['bootstrap'],
		Class['postgresql::server'],
		Package['redis-server']
	]
}

# ------------------------------------------------------------------------------
# -- Phoebo Web UI
# ------------------------------------------------------------------------------

class { 'phoebo_webui':
	base_dir => '/vagrant/Data/Phoebo',
	require => Anchor['common::end']
}