Exec { timeout => 300 }

$r1_keystone_1_ip = "10.0.0.4"
$r1_proxy_1_ip = "10.0.0.6"
$r1_storage_1_ip = "10.0.0.5"
$r1_storage_2_ip = "10.0.0.5"


# install all swift storage servers together
class { 'swift::storage::all':
  storage_local_net_ip => $r1_storage_1_ip,
  allow_versions => true,
  require => Class['swift'],
}

if(!defined(File['/srv/node'])) {
  file { '/srv/node':
    owner  => 'swift',
    group  => 'swift',
    ensure => directory,
    require => Package['openstack-swift'],
  }
}

swift::ringsync{["account","container","object"]:
    ring_server => $r1_proxy_1_ip,
    before => Class['swift::storage::all'],
    require => Class['swift'],
}




swift::storage::ext4{"device1":
  device => "/dev/sdb1",
}


class { 'ssh::server::install': }

Class['swift'] -> Service <| |>
class { 'swift':
    # not sure how I want to deal with this shared secret
    swift_hash_suffix => 'ce9e2f0170264242',
    package_ensure    => latest,
}
