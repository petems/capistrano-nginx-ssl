#capistrano-nginx-ssl

An example of how to configure nginx with ssl and Puppet.

##Getting it working

###Vagrant

```
vagrant up
vagrant ssh
#A hacky way to get the default vagrant user to work for everything
sudo adduser vagrant root
sudo apt-get update
sudo apt-get install git -y
#Create a public key and add it to github in some way...
sudo useradd -s /bin/false nginx
```

###Deploy

```
bundle install
vagrant up
bundle exec cap vagrant deploy
```

###Testing SSH is working with curl


```
cd /etc/ssl/CA/certs
curl -v -s -k --key client1.key --cert client1.crt https://192.168.30.15
# Sucess!

curl -v -s -k --key client2.key --cert client2.crt https://192.168.30.15
# Will fail, key has been revoked
```
