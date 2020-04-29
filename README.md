This is a rough draft of a bolt plan that installs and sets up an LDAP server in a docker container.

Yes, I know it is a terrible idea to ship certificates along with the package.  I will replace this with openssl commands soon.

Usage:

/opt/puppetlabs/bin/bolt plan run ldap_server_setup::setup -m modules:.. -t TARGETS
  

Steps:

1. This does require bolt, so install it first.  I used a bolt.yaml file of:

```
# cat ~/.puppetlabs/bolt/bolt.yaml
ssh:
  user: root
  private-key: ~/.ssh/id_rsa-acceptance
  host-key-check: false
```

Of course, this will differ based on setup.

2. Switch into the ldap_server_setup directory
3. Create a directory for forge modules: 

```# mkdir modules```

4. Install modules locally:

```
# /opt/puppetlabs/bin/bolt puppetfile install -m modules --puppetfile ./Puppetfile
```

5. Use the setup plan to install an LDAP server on a target node:

```
# /opt/puppetlabs/bin/bolt plan run ldap_server_setup::setup -m modules:.. -t <TARGET>
```

Once installed, either PE or CDPE can be set up to use it.  It defaults to a bind dn user of `cn=Service Bind User.dc=puppetdebug,dc=vlan` with a password of `password`.  There are two other users present initially:

```
User: "ldapuser1@puppetdebug.vlan"
Password: "ldapuser1"
User: "ldapuser2@puppetdebug.vlan"
Password:  "ldapuser2"
```

Along with a group called `admins`.  All of these can be altered by changing the ldif files prior to installation.  After installation, normal ldapmodify commands will need to be used to make updates to the existing LDAP server.


There are also a couple tasks for connecting PE and CDPE to the created LDAP server:

```
# /opt/puppetlabs/bin/bolt task run ldap_server_setup::connectcdpe -m modules:.. -t <target CDPE host> ldap_host=<LDAP server> root_user="<CDPE root user> root_password=<CDPE password>
```

```
# /opt/puppetlabs/bin/bolt task run ldap_server_setup::connectpe -m modules:.. -t <target PE master> ldap_server_hostname=<LDAP server>
```

To setup CDPE manually to use this LDAP server, add settings as per the following:

![CDPE Settings](/cdpe-settings.png)

To setup PE manually, use the `ds` endpoint to inject the following:

```
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
    "hostname": "ldap.puppetdebug.vlan",
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
```

Change the "hostname" to match the target where the bolt plan installed the ldap server.

