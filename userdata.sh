#!/bin/bash
yum -y update
yum -y install wget puppet git unzip
cd /etc; rm -rf puppet
git clone https://github.com/mcgonagle/puppet.git
puppet apply --verbose --debug --modulepath=/etc/puppet/modules /etc/puppet/manifest.conf
mkdir /mnt/ebs
mkfs -t ext4 /dev/xvdf
mount /dev/xvdf /mnt/ebs
