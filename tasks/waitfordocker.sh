#!/bin/bash
while [ $(docker logs ldap 2>&1 |grep "slapd starting" |wc -l) -lt 2 ]; do 
  echo "Waiting for slapd to start"; 
  sleep 5; 
done

echo "LDAP container running!"
docker logs ldap 2>&1 |tail -1
