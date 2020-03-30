plan ldap_server_setup::install_docker(
  TargetSpec $targets,
) {
  $targets.apply_prep

  apply($targets) {
    include docker

    docker::run { 'ldap':
      image   => 'osixia/openldap:1.2.3',
      ports   => ['389:389', '636:636'],
      command => '--loglevel=debug',
      volumes => [
                         'ldap_data:/var/lib/ldap', 
                         'ldap_config:/etc/ldap/slapd.d', 
                         '/etc/testldap/certs:/container/service/slapd/assets/certs'
                        ],
      pull_on_start    => true,
      hostname         => 'ldap.puppetdebug.vlan',
      env              => [
                         "LDAP_ORGANISATION=Puppet Inc.", 
                         "LDAP_DOMAIN=puppetdebug.vlan",
                         "LDAP_READONLY_USER=true",
                         "LDAP_READONLY_USER_USERNAME=Service Bind User",
                         "LDAP_READONLY_USER_PASSWORD=password",
                         "LDAP_TLS_CRT_FILENAME=ldap.crt",
                         "LDAP_TLS_KEY_FILENAME=ldap.key",
                         "LDAP_TLS_CA_CRT_FILENAME=ca.pem",
                         "LDAP_TLS_VERIFY_CLIENT=try",
                        ],
    }
  }

  $result = run_task(
    'ldap_server_setup::waitfordocker',
    $targets,
  )

  return $result
}
