class base_packages {
  package {
    [
    'curl'
    ]:
    ensure => installed
  }
}

class nginx {

  package { "nginx":
  ensure => present,
}

file { '/var/www':
ensure => link,
target => "/vagrant",
notify => Service['nginx'],
force  => true
}

file { '/etc/nginx/sites-enabled/default':
  ensure  => present,
  mode    => '0644',
  owner    => 'root',
  source  => 'puppet:///files/modules/nginx/etc/default'
}

}

class openssl {

  Exec { path => '/usr/bin:/bin:/usr/sbin:/sbin' }

  File {
    owner => 'root',
    group => 'root',
    mode  => '0640',
  }

  file { '/etc/ssl/CA/' :
  ensure  => 'directory',
  recurse => true,
}

file { '/etc/nginx/ssl' :
ensure  => 'directory',
recurse => true,
require => Class["nginx"]
}

  # Creating file structure for CA
  file {
    '/etc/ssl/openssl.cnf' :
    ensure  => present,
    source  => 'puppet:///templates/openssl.cnf.erb';
    "/etc/ssl/CA/certs" :
    ensure  => directory,
    require => File['/etc/ssl/CA'];
    "/etc/ssl/CA/revoked" :
    ensure  => directory,
    require => File['/etc/ssl/CA'];
    "/etc/ssl/CA/crls" :
    ensure  => directory,
    require => File['/etc/ssl/CA'];
    "/etc/ssl/CA/newcerts" :
    ensure  => directory,
    require => File['/etc/ssl/CA'];
    "/etc/ssl/CA/private" :
    ensure  => directory,
    require => File['/etc/ssl/CA'];
    "/etc/ssl/CA/index.txt" :
    ensure  => present,
    require => File['/etc/ssl/CA'];
    "/etc/ssl/CA/serial" :
    ensure  => present,
    content => '01',
    replace => false,
    require => File['/etc/ssl/CA'];
    "/etc/ssl/CA/crlnumber" :
    ensure  => present,
    content => '01',
    replace => false,
    require => File['/etc/ssl/CA'];
  }

  exec{'create-ca-certificate' :
  command => "/usr/bin/openssl req -nodes -new -subj '/C=GB/ST=GreaterLondon/L=London/O=IT/CN=localhost' -x509 -keyout /etc/ssl/CA/private/cakey.pem -out /etc/ssl/CA/cacert.pem -days 365",
  creates => "/etc/ssl/CA/cacert.pem",
  require => File[
  '/etc/ssl/openssl.cnf',
  "/etc/ssl/CA/certs",
  "/etc/ssl/CA/crls",
  "/etc/ssl/CA/newcerts",
  "/etc/ssl/CA/private",
  "/etc/ssl/CA/index.txt",
  "/etc/ssl/CA/serial",
  "/etc/ssl/CA/crlnumber",
  "/etc/ssl/CA/revoked"
  ],
}

exec{'create-crl-list' :
command     => "/usr/bin/openssl ca -gencrl -out /etc/ssl/CA/crls/crl.pem",
creates     => "/etc/ssl/CA/crls/crl.pem",
require     => Exec['create-ca-certificate'],
before      => Service['nginx'],
}

file{'/etc/nginx/ssl/ca.crt' :
ensure  => link,
target  => "/etc/ssl/CA/cacert.pem",
require => [
Exec['create-ca-certificate'],
File['/etc/nginx/ssl'],
],
}

file{'/etc/nginx/ssl/crl.pem' :
ensure  => link,
target  => "/etc/ssl/CA/crls/crl.pem",
require => [
Exec['create-crl-list'],
File['/etc/nginx/ssl'],
],
}

  exec {'generate-new-server-key-nginx' :
  command  => '/usr/bin/openssl genrsa -des3 -passout pass:testpass -out /etc/nginx/ssl/server.key 2048; cp /etc/nginx/ssl/server.key /etc/nginx/ssl/server.key.orig; /usr/bin/openssl rsa -passin pass:testpass -in /etc/nginx/ssl/server.key.orig -out /etc/nginx/ssl/server.key; rm -f /etc/nginx/ssl/server.key.orig',
  unless   => '[ -e /etc/nginx/ssl/server.key ]',
  require  => File['/etc/nginx/ssl'],
}

  exec {'generate-cert-request-nginx' :
  command  => "/usr/bin/openssl req -new -subj '/C=GB/ST=GreaterLondon/L=London/O=IT/CN=localhost' -key /etc/nginx/ssl/server.key -out /etc/nginx/ssl/server.csr",
  unless   => '[ -e /etc/nginx/ssl/server.crt ]',
  require  => [
  File['/etc/nginx/ssl'],
  Exec['generate-new-server-key-nginx'],
  ],
}

  exec {'sign-certificate-nginx' :
  command  => '/usr/bin/openssl x509 -req -days 365 -in /etc/nginx/ssl/server.csr -signkey /etc/nginx/ssl/server.key -out /etc/nginx/ssl/server.crt; rm -f /etc/nginx/ssl/server.csr',
  unless   => '[ -e /etc/nginx/ssl/server.crt ]',
  require  => [
  Exec['generate-new-server-key-nginx'],
  Exec['generate-cert-request-nginx'],
  ],
}

  file {'/etc/nginx/ssl/server.crt' :
  ensure  => present,
  require => [
  File['/etc/nginx/ssl'],
  Exec['generate-new-server-key-nginx'],
  Exec['generate-cert-request-nginx'],
  Exec['sign-certificate-nginx'],
  ],
  notify  => Service['nginx'],
}

  file {'/etc/nginx/ssl/server.key' :
  ensure  => present,
  require => [
  File['/etc/nginx/ssl'],
  Exec['generate-new-server-key-nginx'],
  Exec['generate-cert-request-nginx'],
  Exec['sign-certificate-nginx'],
  ],
  notify  => Service['nginx'],
}



exec{'create-client1-certificate' :
command => '/usr/bin/openssl req -nodes -new -subj "/C=GB/ST=GreaterLondon/L=London/O=IT/CN=client1" -keyout client1.key -out client1.csr',
cwd     => "/etc/ssl/CA/certs/",
creates => [
"/etc/ssl/CA/certs/client1.key",
"/etc/ssl/CA/certs/client1.csr",
],
require => [
Exec['create-ca-certificate'],
],
}

exec{'sign-client1-certificate' :
command => '/usr/bin/openssl ca -out client1.crt -in client1.csr -policy policy_anything -batch',
cwd     => "/etc/ssl/CA/certs/",
creates => "/etc/ssl/CA/certs/client1.crt",
require => Exec['create-client1-certificate'],
}

exec{'create-client2-certificate' :
command => '/usr/bin/openssl req -nodes -new -subj "/C=GB/ST=GreaterLondon/L=London/O=IT/CN=client2" -keyout client2.key -out client2.csr',
cwd     => "/etc/ssl/CA/certs/",
creates => [
"/etc/ssl/CA/certs/client2.key",
"/etc/ssl/CA/certs/client2.csr",
],
require => [
Exec['create-ca-certificate'],
],
}

exec{'sign-client2-certificate' :
command => '/usr/bin/openssl ca -out client2.crt -in client2.csr -policy policy_anything -batch',
cwd     => "/etc/ssl/CA/certs/",
creates => "/etc/ssl/CA/certs/client2.crt",
require => Exec['create-client2-certificate'],
}

exec{'revoke-client2-certificate' :
command => '/usr/bin/openssl ca -revoke client2.crt && /bin/cp client2.crt ../revoked',
cwd     => "/etc/ssl/CA/certs/",
creates => "/etc/ssl/CA/revoked/client2.crt",
require => Exec['sign-client2-certificate'],
notify  => Exec['create-crl-list'],
}
}

service { "nginx":
ensure => running,
require => [
Exec["revoke-client2-certificate"],
Package["nginx"],
],
}

file { '/var/www/index.html':
ensure  => present,
source  => '/etc/puppet/files/index.html'
}

exec { 'apt-get update':
command => '/usr/bin/apt-get update'
}

include base_packages
include nginx
include openssl
