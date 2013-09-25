#!/bin/sh
set -x
set -e

cd /home/vagrant/vcap/scripts

./mysql_ctl.sh start &
./nats_ctl.sh start &
./mysql_gateway_ctl.sh start &

# wait for mysqld to start
sleep 5
./mysql_node_ctl.sh start &
