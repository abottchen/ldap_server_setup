plan ldap_server_setup::populate_ldap_entries(
  TargetSpec $targets,
) {
  $targets.apply_prep

  apply($targets) {
    package { 'openldap-clients':
      ensure => installed,
    }
  }


  upload_file('ldap_server_setup/ou.ldif', '/etc/ldapserver/ou.ldif', $targets, '_run_as' => 'root')
  upload_file('ldap_server_setup/user.ldif', '/etc/ldapserver/user.ldif', $targets, '_run_as' => 'root')
  upload_file('ldap_server_setup/groups.ldif', '/etc/ldapserver/groups.ldif', $targets, '_run_as' => 'root')
  upload_file('ldap_server_setup/indexmod.ldif', '/var/lib/docker/volumes/ldap_data/_data/indexmod.ldif', $targets, '_run_as' => 'root')

  apply($targets) {
    exec { 'import ou':
      command => 'ldapadd -x -H ldap://localhost -D "cn=admin,dc=puppetdebug,dc=vlan" -w admin -f /etc/ldapserver/ou.ldif',
      path    => '/usr/bin',
      onlyif  => 'ldapsearch -h $(hostname -f) -b dc=puppetdebug,dc=vlan -D "cn=admin,dc=puppetdebug,dc=vlan" -w admin "(&(objectclass=organizationalunit)(|(ou=People)(ou=Group)))" | grep -i "numResponses: 1"',
    }

    exec { 'import user':
      command => 'ldapadd -x -H ldap://localhost -D "cn=admin,dc=puppetdebug,dc=vlan" -w admin -f /etc/ldapserver/user.ldif',
      path    => '/usr/bin',
      onlyif  => 'ldapsearch -h $(hostname -f) -b dc=puppetdebug,dc=vlan -D "cn=admin,dc=puppetdebug,dc=vlan" -w admin "(&(objectclass=person)(|(cn=ldapuser1)(cn=ldapuser2)))" | grep -i "numResponses: 1"',
    }

    exec { 'import groups':
      command => 'ldapadd -x -H ldap://localhost -D "cn=admin,dc=puppetdebug,dc=vlan" -w admin -f /etc/ldapserver/groups.ldif',
      path    => '/usr/bin',
      onlyif  => 'ldapsearch -h $(hostname -f) -b dc=puppetdebug,dc=vlan -D "cn=admin,dc=puppetdebug,dc=vlan" -w admin "(&(objectclass=posixGroup)(cn=admins))" | grep -i "numResponses: 1"',
    }

    exec { 'import indexmod':
      command => 'docker exec -i ldap ldapadd -Y EXTERNAL -H ldapi:/// -f ./var/lib/ldap/indexmod.ldif',
      path    => '/usr/bin',
      onlyif  => 'docker exec -i ldap ldapsearch -Y EXTERNAL -H ldapi:/// -b cn=config "(&(olcDatabase={1}mdb)(olcDbIndex= ou eq))" 2>&1 | grep -i "numResponses: 1"',
    }
  }
}
