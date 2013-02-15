# Class: mysql
#
#   This class installs mysql client software.
#
# Parameters:
#   [*package_name*]  - The name of the mysql client package.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mysql (
  $package_name   = $mysql::params::client_package_name,
  $package_ensure = 'present'
) inherits mysql::params {

  if $package_name == 'mysql55' {
    file { '/tmp/yum-shell-mysql55':
      content => "
                  remove  mysql-libs
                  install ${package_name} mysql55-libs mysqlclient16 
                  run",
    }
    file { '/tmp/yum-shell-return':
      content => "install cronie cronie-anacron crontabs postfix sysstat perl-DBD-MySQL MySQL-python
                  run",
    }

    exec { 'yum-shell-mysql':
        command => "yum -y shell /tmp/yum-shell-mysql && yum -y shell /tmp/yum-shell-return",
        unless  => "rpm -q ${package_name}",
        notify  => Class['postfix']   
    }
    File['/tmp/yum-shell-mysql55','/tmp/yum-shell-return'] -> Exec['yum-shell-mysql'] -> Package ['mysql_client']

  } 

  package { 'mysql_client':
    ensure => $package_ensure,
    name   => $package_name,
  }

}
