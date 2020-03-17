#!/bin/bash
ldapsearch -h $(hostname -f) -b dc=puppetdebug,dc=vlan -D "cn=admin,dc=puppetdebug,dc=vlan" -w admin cn
