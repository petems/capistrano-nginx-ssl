#capistrano-nginx-ssl

An example of how to configure nginx with ssl and Puppet.

##Getting it working

###Deploy

```
bundle install
vagrant up
bundle exec cap vagrant deploy
```

###Testing SSH is working with curlCurl


```
cd /etc/ssl/CA/certs
curl -v -s -k --key client1.key --cert client1.crt https://192.168.30.15
# Sucess!

curl -v -s -k --key client2.key --cert client2.crt https://192.168.30.15
# Will fail, key has been revoked
```
