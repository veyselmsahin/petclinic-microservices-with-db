
#! /bin/bash
# update OS
dnf update -y

# set server hostname
hostnamectl set-hostname jenkins-server

# install git
dnf install git -y

# install java 11
dnf install java-17-amazon-corretto -y

# install jenkins
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
dnf upgrade -y
dnf install jenkins -y
systemctl enable --now jenkins

# install docker
dnf install -y docker
systemctl enable --now docker
usermod -aG docker ec2-user
usermod -aG docker jenkins

# configure docker for Jenkins
if [ -f /lib/systemd/system/docker.service ]; then
  cp /lib/systemd/system/docker.service /lib/systemd/system/docker.service.bak
  sed -i 's/^ExecStart=.*/ExecStart=\/usr\/bin\/dockerd -H tcp:\/\/127.0.0.1:2376 -H unix:\/\/\/var\/run\/docker.sock/g' /lib/systemd/system/docker.service
  systemctl daemon-reload
  systemctl restart docker
fi

# install docker compose
DOCKER_COMPOSE_VERSION="v2.17.3"
curl -SL https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# install python 3 and pip
dnf install -y python3-pip python3-devel

# install ansible and boto libraries
pip3 install ansible boto3 botocore

# install terraform
TERRAFORM_VERSION="1.4.6"
wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin
rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip
