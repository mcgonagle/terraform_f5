#!/bin/bash -v

sudo yum install -y gcc python27 python27-devel python27-pip libffi-devel openssl-devel git httpd

sudo /usr/bin/pip-2.7 install --upgrade ansible

sudo /usr/bin/pip-2.7install ansible-lint

sudo /usr/bin/pip-2.7 install ansible-review 

sudo /usr/bin/pip-2.7 install bigsuds

sudo /usr/bin/pip-2.7 install f5-sdk

cd /home/ec2-user

/usr/bin/wget http://mirrors.jenkins.io/war-stable/latest/jenkins.war

sudo service httpd start
