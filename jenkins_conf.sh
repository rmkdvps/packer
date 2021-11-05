#!/bin/bash -x

#install docker v1
sudo apt-get update && \
apt-get -y --no-install-recommends install apt-transport-https \
ca-certificates \
curl \
gnupg2 \
software-properties-common && \
curl -4fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg > /tmp/dkey; apt-key add /tmp/dkey && \
add-apt-repository \
"deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
$(lsb_release -cs) \
stable"
apt-get update && \
apt-get -y --no-install-recommends install docker-ce && \
apt-get clean

#add users/groups
useradd jenkins
usermod -aG docker jenkins

HOST_UID=$(id -u jenkins) && \
HOST_GID=$(echo $(getent group | grep docker) | awk -F ":" '{print $3}') && \
echo $HOST_UID && \
echo $HOST_GID

cd /tmp

docker build \
-t jenkins-docker:latest \
--build-arg HOST_UID=$HOST_UID \
--build-arg HOST_GID=$HOST_GID \
.

mkdir /var/jenkins_files
sudo chgrp -R jenkins /var/jenkins_files
sudo chown -R jenkins /var/jenkins_files

docker run -d -it -p 8080:8080 -p 50000:50000 \
-v /var/jenkins_files:/var/jenkins_home \
-v /var/run/docker.sock:/var/run/docker.sock \
--restart unless-stopped \
jenkins-docker:latest

