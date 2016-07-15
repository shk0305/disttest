Exec { timeout => 300 }

$r1_keystone_1_ip = "10.0.0.4"
$r1_proxy_1_ip = "10.0.0.6"
$r1_storage_1_ip = "10.0.0.5"
$r1_storage_2_ip = "10.0.0.5"


#$mysql_package_name = "mariadb-galera-server"  # centos
$mysql_package_name = "mariadb-server-5.5" #ubuntu
class {"mysql::server":
    package_name => $mysql_package_name,
    config_hash => {bind_address => "0.0.0.0",
                    default_engine => "InnoDB",
                    root_password => "openstack",}
}


class {"keystone::db::mysql":
    user          => 'keystone_admin',
    password      => "openstack",
    allowed_hosts => "%",
    charset       => "utf8",
}
