# See: http://openresty.org/#Installation
class openresty {

	package { "nginx":
		ensure => absent
	}

	->

	package {
		[
			'libreadline-dev',
			'libncurses5-dev',
			'libpcre3-dev',
			'libssl-dev',
			'perl',
			'make'
		]:
		ensure => present
	}

	->

	exec { "download-openresty-tarball":
		command => "/usr/bin/wget -q http://openresty.org/download/ngx_openresty-1.7.10.1.tar.gz -O /tmp/ngx_openresty-1.7.10.1.tar.gz",
		creates => "/tmp/ngx_openresty-1.7.10.1.tar.gz",
		unless => "/usr/bin/test -f /usr/local/openresty/nginx/sbin/nginx"
	}

	~>

	exec { "unpack-openresty":
		command => "/bin/tar xzvf ngx_openresty-1.7.10.1.tar.gz",
		cwd => "/tmp",
		creates => "/tmp/ngx_openresty-1.7.10.1",
		refreshonly => true
	}

	~>

	exec { "configure-openresty":
		command => "/tmp/ngx_openresty-1.7.10.1/configure",
		cwd => "/tmp/ngx_openresty-1.7.10.1",
		creates => "/tmp/ngx_openresty-1.7.10.1/Makefile",
		refreshonly => true
	}

	~>

	exec { "compile-and-install-openresty":
		command => "/usr/bin/make && /usr/bin/make install",
		cwd => "/tmp/ngx_openresty-1.7.10.1",
		creates => "/usr/local/openresty/nginx/sbin/nginx",
		refreshonly => true
	}

	~>

	exec { "cleanup-openresty":
		command => "/bin/rm -rf /tmp/ngx_openresty*",
		refreshonly => true
	}

	file { "/etc/nginx":
		ensure => directory
	}

	->

	file { "/etc/nginx/vhosts":
		ensure => directory
	}

	->

	file { "/etc/nginx/nginx.conf":
		ensure => present,
		content => template('openresty/nginx.conf.erb')
	}

	file { "/etc/init/nginx.conf":
		ensure => present,
		content => template('openresty/upstart-init.conf')
	}

	service { 'nginx':
		ensure => 'running',
		require => [
			File["/etc/init/nginx.conf"],
			File["/etc/nginx/nginx.conf"],
			Exec["compile-and-install-openresty"]
		]
	}
}

define nginx::vhost_confd(
	$ensure  = 'file',
	$content = undef
) {
	file { "/etc/nginx/vhosts/${name}.conf":
		ensure => $ensure,
		content => $content
	}
}

Nginx::Vhost_confd <| |> ~> Service['nginx']