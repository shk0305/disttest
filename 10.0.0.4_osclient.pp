Exec { timeout => 300 }

$r1_keystone_1_ip = "10.0.0.4"
$r1_proxy_1_ip = "10.0.0.6"
$r1_storage_1_ip = "10.0.0.5"
$r1_storage_2_ip = "10.0.0.5"


$clientdeps = ["python-iso8601"]
package { $clientdeps: }

$clientlibs = ["python-novaclient", "python-keystoneclient", "python-glanceclient", "python-swiftclient", "python-cinderclient", "python-openstackclient"]
package { $clientlibs: }

$rcadmin_content = "export OS_USERNAME=admin
export OS_TENANT_NAME=admin
export OS_PASSWORD=openstack
export OS_AUTH_URL=http://$r1_keystone_1_ip:5000/v2.0/
export PS1='[\\u@\\h \\W(keystone_admin)]\\$ '
"

file {"${::home_dir}/keystonerc_admin":
   ensure  => "present",
   mode => '0600',
   content => $rcadmin_content,
}

if 'n' == 'y' {
   file {"${::home_dir}/keystonerc_demo":
      ensure  => "present",
      mode => '0600',
      content => "export OS_USERNAME=demo
export OS_TENANT_NAME=demo
export OS_PASSWORD=openstack
export OS_AUTH_URL=http://$r1_keystone_1_ip:5000/v2.0/
export PS1='[\\u@\\h \\W(keystone_demo)]\\$ '
",
   }
}

if false {
    file {"/root/keystonerc_admin":
       ensure => present,
       owner => 'root',
       group => 'root',
       mode => '0600',
       content => $rcadmin_content,
    }
}
