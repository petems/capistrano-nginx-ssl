#capistrano-nginx-ssl

An example of how to configure nginx with ssl and Puppet.

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

Ideally, you'd only have to run the following steps:

```
bundle install
vagrant up
bundle exec cap vagrant deploy
```
