#!/bin/bash
CERTDIR=/etc/ldapserver/certs

echo 0001 > /etc/pki/CA/serial
touch /etc/pki/CA/index.txt

openssl genrsa -passout pass:puppetlabs -aes256 -out ${CERTDIR}/ca.key.pem
openssl req -new -x509 -days 3650 -passin pass:puppetlabs -subj "/C=US/ST=Oregon/L=Portland/O=Puppet/CN=$(hostname -f)" -key ${CERTDIR}/ca.key.pem -extensions v3_ca -out ${CERTDIR}/ca.pem
openssl genrsa -out ${CERTDIR}/ldap.key
openssl req -new -subj "/C=US/ST=Oregon/L=Portland/O=Puppet/CN=ldap.puppetdebug.vlan" -key ${CERTDIR}/ldap.key -out ${CERTDIR}/ldap.csr
openssl ca -batch -passin pass:puppetlabs -keyfile ${CERTDIR}/ca.key.pem -cert ${CERTDIR}/ca.cert.pem -in ${CERTDIR}/ldap.csr -out ${CERTDIR}/ldap.crt
