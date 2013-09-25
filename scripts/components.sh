#!/bin/sh

cd /home/vagrant/vcap/scripts

case $1 in

  start)
   ./mysql_ctl.sh start &
   ./nats_ctl.sh start &
   ./mysql_gateway_ctl.sh start &
   ./mysql_node_ctl.sh start &

   echo "Started all components..."
    ;;

  stop)
   ./mysql_ctl.sh stop
   ./mysql_gateway_ctl.sh stop
   ./mysql_node_ctl.sh stop

   ./nats_ctl.sh stop
    ;;

  *)
    echo "Usage: components.sh {start|stop}"

    ;;

esac