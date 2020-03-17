This is a rough draft of a bolt plan that installs and sets up an LDAP server in a docker container.

Yes, I know it is a terrible idea to ship certificates along with the package.  I will replace this with openssl commands soon.

Usage:

bolt plan run ldapserver::setup targets=<target machine>
  

This does require bolt, so install it first.  I used a bolt.yaml file of:

```
# cat ~/.puppetlabs/bolt/bolt.yaml
modulepath: /etc/puppetlabs/code/environments/production/modules:/root/.puppetlabs/bolt/modules:/root/.puppetlabs/bolt/site-modules:/root/.puppetlabs/bolt/site
ssh:
  user: root
  private-key: ~/.ssh/id_rsa
  host-key-check: false
```

Of course, this will differ based on setup.
