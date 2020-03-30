plan ldap_server_setup::setup (
  TargetSpec $targets) {

 run_plan('ldap_server_setup::createcerts', $targets) 
 run_plan('ldap_server_setup::install_docker', $targets) 
 run_plan('ldap_server_setup::populate_ldap_entries', $targets) 
 $response = run_task('ldap_server_setup::test', $targets)

 return $response
}
