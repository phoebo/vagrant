# See: https://github.com/HubSpot/Singularity/blob/master/vagrant/provision-singularity.sh
class singularity {

	# Configuration directory
	file { "/etc/singularity":
		ensure => directory
	}

	->

	# Configuration file
	file { "/etc/singularity/singularity.yaml":
		content => template('singularity/singularity.yaml.erb'),
		ensure => 'present'
		# replace => false
	}

	# Directory for Singularity
	file { "/usr/local/singularity":
		ensure => directory
	}

	->

	# Directory for Singularity binary
	file { "/usr/local/singularity/bin":
		ensure => directory,
	}

	->

	# Download latest Singularity binary
	exec { "download-singularity":
		command => "/usr/bin/wget -q http://search.maven.org/remotecontent?filepath=com/hubspot/SingularityService/0.4.1/SingularityService-0.4.1-shaded.jar -O /usr/local/singularity/bin/SingularityService-0.4.1-shaded.jar",
		creates => "/usr/local/singularity/bin/SingularityService-0.4.1-shaded.jar"
	}

	# Log directory
	file { "/var/log/singularity":
		ensure => directory
	}

	# Init file
	file { "/etc/init/singularity.conf":
		content => template('singularity/init.conf.erb')
	}

	service { "singularity":
		ensure => running,
		require => [
			Exec["download-singularity"],
			File["/var/log/singularity"],
			File["/etc/init/singularity.conf"],
			File["/etc/singularity/singularity.yaml"]
		]
	}


	nginx::vhost_confd { "02_singularity":
		content => template('singularity/nginx.conf.erb')
	}

}