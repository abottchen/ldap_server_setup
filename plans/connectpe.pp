plan ldapserver::connectpe(
  TargetSpec $targets,
) {
  $targets.apply_prep

  apply($targets) {
    file { '/tmp/ds.json':
      ensure   => file,
      source   => 'puppet:///modules/ldap_server_setup/ds.json',
      notify   => Exec['import ou'],
    }

    file { '/etc/ldapserver/user.ldif':
      ensure => file,
      source => 'puppet:///modules/ldap_server_setup/user.ldif',
      notify => Exec['import user'],
    }

    file { '/etc/ldapserver/groups.ldif':
      ensure => file,
      source => 'puppet:///modules/ldap_server_setup/groups.ldif',
      notify => Exec['import groups'],
    }

    file { '/var/lib/docker/volumes/ldap_data/_data/indexmod.ldif':
      ensure => file,
      source => 'puppet:///modules/ldap_server_setup/indexmod.ldif',
      notify => Exec['import indexmod'],
    }

    exec { 'import ou':
      command     => 'ldapadd -x -H ldap://localhost -D "cn=admin,dc=puppetdebug,dc=vlan" -w admin -f /etc/ldapserver/ou.ldif',
      path        => '/usr/bin',
      refreshonly => true,
      require => Package['openldap-clients'],
    }

    exec { 'import user':
      command     => 'ldapadd -x -H ldap://localhost -D "cn=admin,dc=puppetdebug,dc=vlan" -w admin -f /etc/ldapserver/user.ldif',
      path        => '/usr/bin',
      refreshonly => true,
      require => Package['openldap-clients'],
    }

    exec { 'import groups':
      command     => 'ldapadd -x -H ldap://localhost -D "cn=admin,dc=puppetdebug,dc=vlan" -w admin -f /etc/ldapserver/groups.ldif',
      path        => '/usr/bin',
      refreshonly => true,
      require => Package['openldap-clients'],
    }

    exec { 'import indexmod':
      command     => 'docker exec -i ldap ldapadd -Y EXTERNAL -H ldapi:/// -f ./var/lib/ldap/indexmod.ldif',
      path        => '/usr/bin',
      refreshonly => true,
      require => Package['openldap-clients'],
    }
  }
}
