FROM jenkins/jenkins:lts

ARG HOST_UID
ARG HOST_GID

USER root

# Install the latest Docker CE binaries and add user `jenkins` to the docker group
RUN apt-get update && \
apt-get -y --no-install-recommends install apt-transport-https \
ca-certificates \
curl \
gnupg2 \
software-properties-common && \
curl -4fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg > /tmp/dkey; apt-key add /tmp/dkey && \
add-apt-repository \
"deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
$(lsb_release -cs) \
stable" && \
apt-get update && \
apt-get -y --no-install-recommends install docker-ce && \
apt-get clean

RUN usermod -u $HOST_UID jenkins
RUN groupmod -g $HOST_GID docker
RUN usermod -aG docker jenkins

# drop back to the regular jenkins user - good practice
USER jenkins