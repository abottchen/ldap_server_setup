plan ldapserver::populate_ldap_entries(
  TargetSpec $targets,
) {
  $targets.apply_prep

  apply($targets) {
    package { 'openldap-clients':
      ensure => installed,
    }

    file { '/etc/ldapserver/ou.ldif':
      ensure   => file,
      source   => 'puppet:///modules/ldap_server_setup/ou.ldif',
    }

    file { '/etc/ldapserver/user.ldif':
      ensure => file,
      source => 'puppet:///modules/ldap_server_setup/user.ldif',
    }

    file { '/etc/ldapserver/groups.ldif':
      ensure => file,
      source => 'puppet:///modules/ldap_server_setup/groups.ldif',
    }

    file { '/var/lib/docker/volumes/ldap_data/_data/indexmod.ldif':
      ensure => file,
      source => 'puppet:///modules/ldap_server_setup/indexmod.ldif',
    }

    exec { 'import ou':
      command => 'ldapadd -x -H ldap://localhost -D "cn=admin,dc=puppetdebug,dc=vlan" -w admin -f /etc/ldapserver/ou.ldif',
      path    => '/usr/bin',
      onlyif  => 'ldapsearch -h $(hostname -f) -b dc=puppetdebug,dc=vlan -D "cn=admin,dc=puppetdebug,dc=vlan" -w admin "(&(objectclass=organizationalunit)(|(ou=People)(ou=Group)))" | grep -i "numResponses: 1"',
      require => [Package['openldap-clients'], File['/etc/ldapserver/ou.ldif']],
    }

    exec { 'import user':
      command => 'ldapadd -x -H ldap://localhost -D "cn=admin,dc=puppetdebug,dc=vlan" -w admin -f /etc/ldapserver/user.ldif',
      path    => '/usr/bin',
      onlyif  => 'ldapsearch -h $(hostname -f) -b dc=puppetdebug,dc=vlan -D "cn=admin,dc=puppetdebug,dc=vlan" -w admin "(&(objectclass=person)(|(cn=ldapuser1)(cn=ldapuser2)))" | grep -i "numResponses: 1"',
      require => [Package['openldap-clients'], File['/etc/ldapserver/user.ldif']],
    }

    exec { 'import groups':
      command => 'ldapadd -x -H ldap://localhost -D "cn=admin,dc=puppetdebug,dc=vlan" -w admin -f /etc/ldapserver/groups.ldif',
      path    => '/usr/bin',
      onlyif  => 'ldapsearch -h $(hostname -f) -b dc=puppetdebug,dc=vlan -D "cn=admin,dc=puppetdebug,dc=vlan" -w admin "(&(objectclass=posixGroup)(cn=admins))" | grep -i "numResponses: 1"',
      require => [Package['openldap-clients'], File['/etc/ldapserver/groups.ldif']],
    }

    exec { 'import indexmod':
      command => 'docker exec -i ldap ldapadd -Y EXTERNAL -H ldapi:/// -f ./var/lib/ldap/indexmod.ldif',
      path    => '/usr/bin',
      onlyif  => 'docker exec -i ldap ldapsearch -Y EXTERNAL -H ldapi:/// -b cn=config "(&(olcDatabase={1}mdb)(olcDbIndex= ou eq))" 2>&1 | grep -i "numResponses: 1"',
      require => [Package['openldap-clients'], File['/var/lib/docker/volumes/ldap_data/_data/indexmod.ldif']],
    }
  }
}
