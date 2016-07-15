Exec { timeout => 300 }

$r1_keystone_1_ip = "10.0.0.4"
$r1_proxy_1_ip = "10.0.0.6"
$r1_storage_1_ip = "10.0.0.5"
$r1_storage_2_ip = "10.0.0.5"


$mysql_url = join([ "mysql://keystone_admin:openstack@", $r1_keystone_1_ip, "/keystone" ])
class {"keystone":
    admin_token => "608bcd54a9d346b7a9a642924c284950",
    sql_connection => $mysql_url,
    token_format => "PKI",
    verbose => true,
    debug => true
}

class {"keystone::roles::admin":
    email => "test@test.com",
    password => "openstack",
    admin_tenant => "admin"
}

class {"keystone::endpoint":
    public_address  => $r1_keystone_1_ip,
    admin_address  => $r1_keystone_1_ip,
    internal_address  => $r1_keystone_1_ip
}

# Run token flush every minute (without output so we won't spam admins)
cron { 'token-flush':
    ensure => 'present',
    command => '/usr/bin/keystone-manage token_flush >/dev/null 2>&1',
    minute => '*/1',
    user => 'keystone',
    require => [User['keystone'], Group['keystone']],
} -> service { 'cron':
    ensure => 'running',
    enable => true,
}


class { 'swift::keystone::auth':
  public_address  => $r1_proxy_1_ip,
  password => 'openstack'
}
