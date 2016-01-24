#!/bin/bash
# aurora-thermosobserver Apache Aurora Thermos Observer
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
. /etc/sysconfig/aurora-slave

DIST_DIR=/usr/local/aurora

start() {

$DIST_DIR/dist/thermos_observer.pex \
    --port=1338 \
    --log_to_disk=NONE \
    --log_to_stderr=google:INFO

}

stop() {
    	echo -n $"Shutting down $prog: "
    	killproc -p /var/run/thermos-observer.pid $prog
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

