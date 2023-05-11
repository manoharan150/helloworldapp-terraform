#!/bin/bash
#yum update -y
yum install -y jdk1.8.aarch64
yum-config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce.aarch64

systemctl enable docker.service
systemctl start docker.service
systemctl status docker.service

docker run -d -p 8080:8080 -p 8081:8081 manoharan150/hello-worldapp
