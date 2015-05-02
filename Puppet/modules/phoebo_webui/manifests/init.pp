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

	# temp dir
	file { "/tmp/phoebo":
		ensure => 'directory',
		owner => 'vagrant',
		group => 'vagrant'
	}

	package { "postgresql-server-dev-9.3":
		ensure => 'present'
	}

	# bundle install
	exec { "phoebo-bundle-install":
		command => "/usr/local/bin/bundle install && /bin/touch /tmp/phoebo/.bundle-installed",
		cwd => $base_dir,
		user => 'vagrant',
		group => 'vagrant',
		creates => "/tmp/phoebo/.bundle-installed",
		require => [
			File["/tmp/phoebo"],
			Package["postgresql-server-dev-9.3"]
		]
	}

	# rake db:migrate
	exec { "phoebo-db-migration":
		command => "$base_dir/bin/rake db:migrate",
		cwd => $base_dir,
		user => 'vagrant',
		group => 'vagrant',
		require => [
			File["$base_dir/config/database.yml"],
			Postgresql::Server::Db["${$phoebo_dbname}_dev"],
			Exec["phoebo-bundle-install"]
		],
		environment => [
			'HOME=/vagrant/home'
		]
	}

	# config/puma.rb
	file { "$base_dir/config/puma.rb":
		ensure => present,
		content => template('phoebo_webui/puma.rb.erb')
	}

	# upstart config
	file { "/etc/init/phoebo.conf":
		ensure => present,
		content => template('phoebo_webui/upstart-init.conf.erb')
	}

	file { "$base_dir/config/initializers/00_vagrant.rb":
		ensure => present,
		content => template('phoebo_webui/vagrant.rb.erb')
	}

	nginx::vhost_confd { "01_phoebo":
		content => template('phoebo_webui/nginx.conf.erb')
	}

	service { "phoebo":
		ensure => running,
		require => [
			File["/etc/init/phoebo.conf"],
			File["$base_dir/config/initializers/00_vagrant.rb"],
			File["$base_dir/config/puma.rb"],
			File["$base_dir/config/application.yml"],
			Exec["phoebo-db-migration"],
			Service["nginx"]
		],
		enable => true
	}
}