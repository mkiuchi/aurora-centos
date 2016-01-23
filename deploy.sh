#!/usr/bin/env bash
AURORA_HOME=$HOME/aurora


sudo cp auroraScheduler.sh auroraThermosObserver.sh /usr/local/sbin
sudo chmod 0544 /usr/local/sbin/auroraScheduler.sh
sudo chmod 0544 /usr/local/sbin/auroraThermosObserver.sh
sudo cp aurora-master.service aurora-slave.service /lib/systemd/system
sudo cp aurora-master aurora-slave /etc/sysconfig
sudo systemctl daemon-reload

sudo mkdir -p /usr/local/aurora
cd $AURORA_HOME
sudo sh -c 'tar cf - . | ( cd /usr/local/aurora ; tar xf - )'

