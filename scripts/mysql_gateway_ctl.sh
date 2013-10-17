#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $DIR/base.sh

RUN_DIR=$RUN_DIR_BASE/mysql_gateway
LOG_DIR=$LOG_DIR_BASE/mysql_gateway

PIDFILE=$RUN_DIR/mysql_gateway.pid

case $1 in

  start)
    pid_guard $PIDFILE "MySQL gateway"

    make_dir $RUN_DIR
    make_dir $LOG_DIR

    echo $$ > $PIDFILE

    exec $INSTALL_DIR/cf-services-release/src/mysql_service/bin/mysql_gateway \
         -c $CFG_DIR_BASE/mysql_gateway.yml \
         >>$LOG_DIR/mysql_gateway.stdout.log \
         2>>$LOG_DIR/mysql_gateway.stderr.log

    ;;

  stop)
    kill_and_wait $PIDFILE

    ;;

  *)
    echo "Usage: mysql_gateway_ctl {start|stop}"

    ;;

esac
