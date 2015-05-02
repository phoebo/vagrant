# ------------------------------------------------------------------------------
# --- APT setup
# ------------------------------------------------------------------------------

class { 'apt': }

# Packages: mesos
apt::source { 'mesosphere':
  location => 'http://repos.mesosphere.io/ubuntu',
  repos => 'main',
  include  => {
    'src' => false,
    'deb' => true,
  },
  key => {
    'id' => '81026D0004C44CF7EF55ADF8DF7D54CBE56151BF',
    'server' => 'keyserver.ubuntu.com'
  }
}

# Packages: lxc-docker
apt::source { 'docker':
  location => 'http://get.docker.io/ubuntu',
  release => 'docker',
  repos => 'main',
  include  => {
    'src' => false,
    'deb' => true,
  },
  key => {
    'id' => '36A1D7869245C8950F966E92D8576A8BA88D21E9',
    'server' => 'keyserver.ubuntu.com'
  }
}

# ------------------------------------------------------------------------------
# --- Common setup
# ------------------------------------------------------------------------------

class { 'bootstrap': }

->

package {
  [
    'curl',
    'python-setuptools',
    'python-pip',
    'python-dev',
    'python-protobuf'
  ]:
  ensure => 'present'
}

->

anchor { 'common::end': }

# ------------------------------------------------------------------------------
# -- Docker
# ------------------------------------------------------------------------------

package { 'lxc-docker':
  ensure => 'present',
  require => [
    Apt::Source['docker'],
    Anchor['common::end']
  ]
}

->

service { 'docker':
  ensure => 'running'
}

exec { 'preload-phoebo-image-builder':
  require => Service['docker'],
  command => '/usr/bin/docker pull phoebo/image-builder:latest'
}

exec { 'preload-phoebo-logspout':
  require => Service['docker'],
  command => '/usr/bin/docker pull phoebo/logspout:latest'
}

# ------------------------------------------------------------------------------
# -- Mesos
# ------------------------------------------------------------------------------

package { 'mesos':
  ensure => 'present',
  require => [
    Apt::Source['mesosphere'],
    Anchor['common::end']
  ]
}

file { '/etc/mesos/zk':
  require => Package['mesos'],
  content => 'zk://phoebo.local:2181/mesos
'
}

file { '/etc/mesos-slave/ip':
  require => Package['mesos'],
  ensure => 'present',
  content => "${ipaddress_eth0}
"
}

file { '/etc/mesos-slave/containerizers':
  require => Package['mesos'],
  notify => Service['mesos-slave'],
  content => 'docker,mesos
'
}

file { '/etc/mesos-slave/executor_registration_timeout':
  require => Package['mesos'],
  notify => Service['mesos-slave'],
  content => '5mins
'
}

service { 'mesos-slave':
  require => [
    Service['docker'],
    Package['mesos'],
    File['/etc/mesos/zk'],
    File['/etc/mesos-slave/containerizers'],
    File['/etc/mesos-slave/executor_registration_timeout']
  ],
  ensure => 'running'
}

service { 'mesos-master':
  require => Package['mesos'],
  ensure => 'stopped'
}



