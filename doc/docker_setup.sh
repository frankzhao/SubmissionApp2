#!/usr/bin/env bash
# Docker Setup

echo "updating repos"
sudo apt-get update

echo "installing dependencies"
sudo apt-get install \
     apt-transport-https \
     ca-certificates \
     curl \
     gnupg2 \
     software-properties-common

echo "adding repository"
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"

echo "Updating repositories"
sudo apt-get update

echo "Installing docker"
sudo apt-get install docker-ce

echo "Configuring docker"
sudo groupadd docker

sudo gpasswd -a subapp2 docker

echo "Installation complete!"