#!/bin/sh

(cat <<EOF
{
    "base_dn": "dc=puppetdebug,dc=vlan",
    "connect_timeout": 10,
    "disable_ldap_matching_rule_in_chain": false,
    "display_name": "My LDAP",
    "group_lookup_attr": "cn",
    "group_member_attr": "memberUid",
    "group_name_attr": "cn",
    "group_object_class": "posixGroup",
    "group_rdn": null,
    "help_link": "",
    "hostname": "$PT_ldap_server_hostname",
    "login": "cn=Service Bind User,dc=puppetdebug,dc=vlan",
    "password": "password",
    "port": 636,
    "search_nested_groups": false,
    "ssl": true,
    "ssl_hostname_validation": false,
    "ssl_wildcard_validation": false,
    "start_tls": false,
    "type": null,
    "user_display_name_attr": "cn",
    "user_email_attr": "mail",
    "user_lookup_attr": "cn",
    "user_rdn": ""
}
EOF
) > /tmp/ds.json

if [ ! -s /tmp/ds.json ]; then
  echo "Unable to create temporary file on target system"
  exit 1
fi

echo "Old DS configuration: "
curl -s https://$(puppet config print certname):4433/rbac-api/v1/ds --cert $(puppet config print hostcert) --key $(puppet config print hostprivkey) --cacert $(puppet config print cacert) | python -m json.tool

echo "New DS configuration: "
curl -X PUT https://$(puppet config print certname):4433/rbac-api/v1/ds --cert $(puppet config print hostcert) --key $(puppet config print hostprivkey) --cacert $(puppet config print cacert) -d "@/tmp/ds.json" -H 'Content-Type: application/json' | python -m json.tool

rm /tmp/ds.json
