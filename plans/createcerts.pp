plan ldap_server_setup::createcerts(
  TargetSpec $targets,
) {
  $targets.apply_prep

  apply($targets) {
    $directories = ['/etc/ldapserver',
      '/etc/ldapserver/certs',
      '/var/lib/ldap',
      '/etc/ldap',
      '/etc/ldap/slapd.d',
    ]
  
    file { $directories:
      ensure => directory,
    }

    file {'/etc/ldapserver/certs/ca.pem':
      ensure => file,
      source => 'puppet:///modules/ldap_server_setup/ca.pem',
    }

    file {'/etc/ldapserver/certs/ldap.key':
      ensure => file,
      source => 'puppet:///modules/ldap_server_setup/ldap.key',
    }

    file {'/etc/ldapserver/certs/ldap.crt':
      ensure => file,
      source => 'puppet:///modules/ldap_server_setup/ldap.key',
    }

    file {'/etc/pki/ca-trust/source/anchors/ca.pem':
      ensure => file,
      source => 'puppet:///modules/ldap_server_setup/ca.pem',
    } ~>

    exec { 'update trust':
      refreshonly => true,
      path        => '/usr/bin',
      command     => 'update-ca-trust extract',
    }
  }
}
