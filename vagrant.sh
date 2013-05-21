#!/bin/bash

sudo adduser vagrant root
sudo apt-get update
sudo apt-get install git -y
sudo useradd -s /bin/false nginx
