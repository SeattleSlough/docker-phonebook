#! /bin/bash
dnf update -y && dnf upgrade -y
dnf install git -y
dnf install docker -y
systemctl start docker
systemctl enable docker
hostnamectl set-hostname docker-api
usermod -a -G docker ec2-user
newgrp docker
curl -SL https://github.com/docker/compose/releases/download/v2.20.3/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
cd /home/ec2-user
TOKEN=${user-data-git-token}
USER=${user-data-git-name}
git clone https://$TOKEN@git.com/$USER/docker-bookstore-api.git api
cd api
docker-compose up -d 