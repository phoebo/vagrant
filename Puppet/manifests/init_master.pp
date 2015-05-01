# Augeas: http://projects.puppetlabs.com/projects/1/wiki/puppet_augeas
# augtool print /augeas//error

# ------------------------------------------------------------------------------
# --- APT setup
# ------------------------------------------------------------------------------

class { 'apt': }

# Packages: mesos
apt::source { 'mesosphere':
  location => 'http://repos.mesosphere.io/ubuntu',
  repos => 'main',

  # Old
  include_src => false,
  include_deb => true,
  key => '81026D0004C44CF7EF55ADF8DF7D54CBE56151BF',
  key_server => 'keyserver.ubuntu.com'

  # include  => {
  #   'src' => false,
  #   'deb' => true,
  # },
  # key => {
  #   'id' => '81026D0004C44CF7EF55ADF8DF7D54CBE56151BF',
  #   'server' => 'keyserver.ubuntu.com'
  # }
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
    'python-protobuf',
    'redis-server'
  ]:
  ensure => 'present'
}

->

anchor { 'common::end': }

class { 'openresty': }
class { 'postgresql::server': }

# ------------------------------------------------------------------------------
# -- Zookeeper
# ------------------------------------------------------------------------------

anchor { 'zookeeper-begin':
  require => Anchor['common::end']
}

->

package { 'zookeeperd':
  ensure => 'present'
}

->

file { '/var/lib/zookeeper/myid':
  content => '1
'
}

->

anchor { 'zookeeper-end': }

# ------------------------------------------------------------------------------
# -- Mesos + Singularity
# ------------------------------------------------------------------------------

package { 'mesos':
  ensure => 'present',
  require => [
    Apt::Source['mesosphere'],
    Anchor['zookeeper-end']
  ]
}

file { '/etc/mesos-master/ip':
  require => Package['mesos'],
  ensure => 'present',
  content => "${ipaddress_eth0}
"
}

->

file { '/etc/mesos-master/hostname':
  require => Package['mesos'],
  ensure => 'present',
  content => "${fqdn}
"
}

->

service { 'mesos-master':
  require => Package['mesos'],
  ensure => 'running'
}

->

class { 'singularity':
  require => Class['openresty']
}

# ------------------------------------------------------------------------------
# -- Phoebo Web UI
# ------------------------------------------------------------------------------

class { 'phoebo_webui':
  base_dir => '/vagrant/Data/Phoebo',
  require => [
    Anchor['common::end'],
    Class['openresty'],
    Service["singularity"],
    Service['nginx'],
    Class['postgresql::server']
  ]
}
