# Augeas: http://projects.puppetlabs.com/projects/1/wiki/puppet_augeas
# augtool print /augeas//error

# ------------------------------------------------------------------------------
# --- Basic setup
# ------------------------------------------------------------------------------

class { 'bootstrap': }

# Some system essentials
package {
	[
		'git-core',
		'curl'
	]:
	ensure => 'installed'
}

if defined( "vcsrepo") {
	Package['git-core'] -> Vcsrepo <| |>
}

# ------------------------------------------------------------------------------
# Add your setup here