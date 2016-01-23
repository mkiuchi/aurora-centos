#!/usr/bin/env bash
AURORA_HOME=$HOME/aurora

cd $AURORA_HOME
mkdir third_party
cd third_party
wget https://svn.apache.org/repos/asf/aurora/3rdparty/centos/7/python/mesos.native-0.25.0-py2.7-linux-x86_64.egg 

cd $AURORA_HOME
./pants binary src/main/python/apache/aurora/kerberos:kaurora_admin
sudo cp dist/kaurora_admin.pex /usr/local/bin/aurora_admin

./pants binary src/main/python/apache/aurora/kerberos:kaurora
sudo cp dist/kaurora.pex /usr/local/bin/aurora

CLASSPATH_PREFIX=dist/resources/main ./gradlew installDist
sudo mkdir -p /var/db/aurora /var/lib/aurora/backups

sudo rm -rf /usr/local/aurora/master /var/db/aurora/*
sudo mesos-log initialize --path="/var/db/aurora"

