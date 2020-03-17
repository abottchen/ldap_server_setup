plan ldapserver::setup (
  TargetSpec $targets) {

 run_plan('ldapserver::createcerts', $targets) 
 run_plan('ldapserver::install_docker', $targets) 
 run_plan('ldapserver::populate_ldap_entries', $targets) 
 $response = run_task('ldapserver::test', $targets)

 return $response
}
