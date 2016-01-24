#!/usr/bin/env bash
sudo rpm -ivh http://ftp.iij.ad.jp/pub/linux/fedora/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
sudo yum -y install unzip wget python-pip python-devel thrift java-1.8.0-openjdk-devel krb5-devel
sudo yum -y groupinstall ‘Development Tools’

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

./pants binary src/main/python/apache/aurora/executor:thermos_executor
./pants binary src/main/python/apache/thermos/runner:thermos_runner
build-support/embed_runner_in_executor.py
chmod +x dist/thermos_executor.pex
./pants binary src/main/python/apache/aurora/tools:thermos_observer
./pants binary src/main/python/apache/aurora/tools:thermos
sudo cp dist/thermos.pex /usr/local/bin/thermos

CLASSPATH_PREFIX=dist/resources/main ./gradlew installDist
sudo mkdir -p /var/db/aurora /var/lib/aurora/backups

sudo rm -rf /usr/local/aurora/master /var/db/aurora/*
sudo mesos-log initialize --path="/var/db/aurora"

