#!/bin/bash
# aurora-scheduler Apache Aurora Scheduler
#

#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# 	http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Source function library.
. /etc/init.d/functions

# Source networking configuration.
. /etc/sysconfig/network

# Source Site-specific configuration
. /etc/sysconfig/aurora-master

DIST_DIR=/usr/local/aurora
prog=aurora-scheduler
lockfile=/var/lock/subsys/$prog

# Environment variables control the behavior of the Mesos scheduler driver (libmesos).
GLOG_v=0
ZKPORT=$(cat /etc/zookeeper/conf/zoo.cfg |grep clientPort=|tail -1|awk -F= '{print $2}')
ZKADDR=$(cat /etc/zookeeper/conf/zoo.cfg |grep clientPortAddress|tail -1|awk -F= '{print $2}')
GLOBAL_CONTAINER_MOUNTS=${GLOBAL_CONTAINER_MOUNTS:-'/opt:/opt:rw'}

rm -rf /usr/local/aurora/master /var/db/aurora/*
mesos-log initialize --path="/var/db/aurora"

# Flags that control the behavior of the JVM.
#env JAVA_OPTS='-Djava.library.path=/usr/lib -Dlog4j.configuration="file:///etc/zookeeper/conf/log4j.properties" -Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005'

start() {
cd /usr/local/aurora
options="-cluster_name=$CLUSTERNAME"
options=$options" -hostname=$HOSTNAME"
options=$options" -http_port=8081"
options=$options" -native_log_quorum_size=1"
options=$options" -zk_endpoints=$ZKADDR:$ZKPORT"
options=$options" -mesos_master_address=$(cat /etc/mesos/zk)"
options=$options" -serverset_path=/aurora/scheduler"
options=$options" -native_log_zk_group_path=/aurora/replicated-log"
options=$options" -native_log_file_path=/var/db/aurora"
options=$options" -backup_dir=/var/lib/aurora/backups"
options=$options" -thermos_executor_path=$DIST_DIR/dist/thermos_executor.pex"
#options=$options" -thermos_executor_flags=\"--announcer-enable --announcer-ensemble $ZKADDR:$ZKPORT\""
#options=$options" -vlog=INFO"
#options=$options" -logtostderr"
options=$options" -allowed_container_types=MESOS,DOCKER"
options=$options" -global_container_mounts=$GLOBAL_CONTAINER_MOUNTS"
#options=$options" -http_authentication_mechanism=BASIC"
options=$options" -use_beta_db_task_store=true"
#options=$options" -shiro_ini_path=etc/shiro.example.ini"
options=$options" -enable_h2_console=true"
options=$options" -tier_config=$DIST_DIR/src/test/resources/org/apache/aurora/scheduler/tiers-example.json"
options=$options" -receive_revocable_resources=true"

#daemon "$DIST_DIR/dist/install/aurora-scheduler/bin/aurora-scheduler $options &"
$DIST_DIR/dist/install/aurora-scheduler/bin/aurora-scheduler $options -thermos_executor_flags="--announcer-enable --announcer-ensemble $ZKADDR:$ZKPORT"

#RETVAL=$?
#if [ $RETVAL -eq 0 ]; then
#  touch $lockfile
#  aurorapid=`ps -efww|grep aurora-scheduler|head -1|awk '{print $2}'`
#  echo $aurorapid > /var/run/aurora-scheduler.pid
#fi

}

stop() {
    	echo -n $"Shutting down $prog: "
    	killproc -p /var/run/aurora-scheduler.pid $prog
    	RETVAL=$?
    	echo
    	[ $RETVAL -eq 0 ] && rm -f $lockfile
    	return $RETVAL
}

# See how we were called.
case "$1" in
  start)
    	start
    	;;
  stop)
    	stop
    	;;
  status)
    	status $prog
    	;;
  restart)
    	stop
    	start
    	;;
  *)
    	echo $"Usage: $0 {start|stop|status|restart}"
    	exit 2
esac

