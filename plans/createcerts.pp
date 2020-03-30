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
  }
  
  upload_file('ldap_server_setup/ca.pem', '/etc/ldapserver/certs/ca.pem', $targets, '_run_as' => 'root')
  upload_file('ldap_server_setup/ldap.key', '/etc/ldapserver/certs/ldap.key', $targets, '_run_as' => 'root')
  upload_file('ldap_server_setup/ldap.crt', '/etc/ldapserver/certs/ldap.crt', $targets, '_run_as' => 'root')
  upload_file('ldap_server_setup/ca.pem', '/etc/pki/ca-trust/source/anchors/ca.pem', $targets, '_run_as' => 'root')
  run_command('/usr/bin/update-ca-trust extract', $targets, '_catch_errors' => true)
}
