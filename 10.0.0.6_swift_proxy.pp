Exec { timeout => 300 }

$r1_keystone_1_ip = "10.0.0.4"
$r1_proxy_1_ip = "10.0.0.6"
$r1_storage_1_ip = "10.0.0.5"
$r1_storage_2_ip = "10.0.0.5"


package { 'curl': ensure => present }

class { 'memcached':
}

class { 'swift::proxy':
  proxy_local_net_ip => $r1_proxy_1_ip,
  pipeline           => [
    #'catch_errors',
    'healthcheck',
    'cache',
    #'ratelimit',
    'authtoken',
    'keystone',
    'staticweb',
    'tempurl',
    #'account_quotas',
    #'container_quotas',
    'proxy-server'
  ],
  account_autocreate => true,
}

# configure all of the middlewares
class { [
    'swift::proxy::catch_errors',
    'swift::proxy::healthcheck',
    'swift::proxy::cache',
    'swift::proxy::staticweb',
    'swift::proxy::tempurl',
    'swift::proxy::account_quotas',
    'swift::proxy::container_quotas'
]: }

class { 'swift::proxy::ratelimit':
    clock_accuracy         => 1000,
    max_sleep_time_seconds => 60,
    log_sleep_time_seconds => 0,
    rate_buffer_seconds    => 5,
    account_ratelimit      => 0
}

class { 'swift::proxy::keystone':
    operator_roles => ['admin', 'SwiftOperator'],
}

class { 'swift::proxy::authtoken':
    admin_user        => 'swift',
    admin_tenant_name => 'services',
    admin_password    => 'openstack',
    # assume that the controller host is the swift api server
    auth_host         => $r1_keystone_1_ip
}

#firewall { '001 swift proxy incoming':
    #proto    => 'tcp',
    #dport    => ['8080'],
    #action   => 'accept'
#}
swift::ringsync{["account","container","object"]:
    ring_server => $r1_proxy_1_ip
}


class { 'ssh::server::install': }

Class['swift'] -> Service <| |>
class { 'swift':
    # not sure how I want to deal with this shared secret
    swift_hash_suffix => 'ce9e2f0170264242',
    package_ensure    => latest
}
