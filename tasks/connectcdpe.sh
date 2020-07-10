#!/bin/bash
ENDPOINT="http://localhost:8080"

COOKIE=`curl -sc - ${ENDPOINT} | grep com.puppet | awk 'NF>1{print $NF}'`
ROOTCOOKIE=`curl -c - -s -D - -H "Cookie:${COOKIE}" -H 'Content-Type: application/json' "${ENDPOINT}/login" -d "{\"op\":\"PfiLogin\", \"content\": {\"email\":\"${PT_root_user}\", \"passwd\":\"${PT_root_password}\"}}" | grep com.puppet | awk '{ print $NF }' |tail -1`

cat > /tmp/saveldapconfiguration.json <<EOF
{
    "content": {
      "name": "MyLDAP",
      "endpointUrl": "ldap://${PT_ldap_host}:389",
      "bindDn": "cn=Service Bind User,dc=puppetdebug,dc=vlan",
      "bindDnPassword": "password",
      "userBaseDn": "ou=People,dc=puppetdebug,dc=vlan",
      "userAttribute": "mail",
      "mailAttribute": "",
      "userBaseFilter": "",
      "groupBaseDn": "ou=Group,dc=puppetdebug,dc=vlan",
      "groupUserAttribute": "dn",
      "groupBaseFilter": "",
      "recursionEnabled": false,
      "isEnabled": true,
      "caCert": "",
      "priority": 1,
      "groupMemberAttribute": "memberUid",
      "groupNameAttribute": "cn",
      "userObjectClass": "person",
      "groupObjectClass": "posixGroup",
      "userMemberAttribute": "",
      "queryWithUserMemberAttribute": false
    },
    "op": "SaveLDAPConfiguration"
}
EOF

curl -sH "Cookie:com.puppet.pipelines.pfi.sid=$ROOTCOOKIE" -H 'Content-Type: application/json' -v "${ENDPOINT}/root/ajax" -d "@/tmp/saveldapconfiguration.json" | python -m json.tool

rm /tmp/saveldapconfiguration.json
