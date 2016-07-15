Exec { timeout => 300 }

$r1_keystone_1_ip = "10.0.0.4"
$r1_proxy_1_ip = "10.0.0.6"
$r1_storage_1_ip = "10.0.0.5"
$r1_storage_2_ip = "10.0.0.5"


class { 'swift::ringbuilder':
  part_power     => '18',
  replicas       => '1',
  min_part_hours => 1,
  require        => Class['swift'],
}

# sets up an rsync db that can be used to sync the ring DB
class { 'swift::ringserver':
  local_net_ip => $r1_proxy_1_ip,
}

@@swift::ringsync { ['account', 'object', 'container']:
 ring_server => $swift_local_net_ip
}

if ($::selinux != "false"){
    selboolean{'rsync_export_all_ro':
        value => on,
        persistent => true,
    }
}

@@ring_object_device { "$r1_storage_1_ip:6000/device1":
 zone        => 2,
 weight      => 10, }
@@ring_container_device { "$r1_storage_1_ip:6001/device1":
 zone        => 2,
 weight      => 10, }
@@ring_account_device { "$r1_storage_1_ip:6002/device1":
 zone        => 2,
 weight      => 10, }
@@ring_object_device { "$r1_storage_2_ip:6000/device2":
 zone        => 1,
 weight      => 10, }
@@ring_container_device { "$r1_storage_2_ip:6001/device2":
 zone        => 1,
 weight      => 10, }
@@ring_account_device { "$r1_storage_2_ip:6002/device2":
 zone        => 1,
 weight      => 10, }

class { 'ssh::server::install': }

Class['swift'] -> Service <| |>
class { 'swift':
    # not sure how I want to deal with this shared secret
    swift_hash_suffix => 'ce9e2f0170264242',
    package_ensure    => latest,
}
