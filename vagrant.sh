#!/bin/bash

sudo adduser vagrant root
sudo apt-get update
sudo apt-get install git puppet -y
id -u nginx &>/dev/null || /usr/sbin/useradd nginx
