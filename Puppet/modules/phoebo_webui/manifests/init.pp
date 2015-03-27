class phoebo_webui (
	$base_dir		= undef
) {
	$phoebo_dbname = hiera('phoebo::db')

	# Dev DB
	postgresql::server::db { "${$phoebo_dbname}_dev":
		user     => hiera('phoebo::dbuser'),
		password => postgresql_password(hiera('phoebo::dbuser'), hiera('phoebo::dbpassword')),
	}

	# Test DB
	postgresql::server::db { "${$phoebo_dbname}_test":
		user     => hiera('phoebo::dbuser'),
		password => postgresql_password(hiera('phoebo::dbuser'), hiera('phoebo::dbpassword')),
	}

	# config/application.yml
	file { "$base_dir/config/application.yml":
		content =>  template('phoebo_webui/application.yml.erb'),
		ensure => 'present',
		replace => false
	}

	# config/database.yml
	file { "$base_dir/config/database.yml":
		content =>  template('phoebo_webui/database.yml.erb'),
		ensure => 'present',
		replace => false
	}

	exec { "phoebo-bundle-install":
		command => "/usr/local/bin/bundle install && /bin/touch $base_dir/.bundle-installed",
		cwd => $base_dir,
		user => 'vagrant',
		group => 'vagrant',
		creates => "$base_dir/.bundle-installed"
	}
}