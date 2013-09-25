#!/bin/bash

source ./base.sh

RUN_DIR=$RUN_DIR_BASE/mysql_node
LOG_DIR=$LOG_DIR_BASE/mysql_node
JOB_DIR=$JOB_DIR_BASE/mysql_node

MIG_DIR=$VCAP_HOME/services_migration

STORE_DIR=$STORE_DIR_BASE/mysql

PIDFILE=$RUN_DIR/mysql_node.pid

case $1 in

  start)
    pid_guard $PIDFILE "MySQL node"

    make_dir $RUN_DIR
    make_dir $LOG_DIR
    make_dir $MIG_DIR

    echo $$ > $PIDFILE

    exec $INSTALL_DIR/cf-services-release/src/mysql_service/bin/mysql_node \
         -c $CFG_DIR_BASE/mysql_node.yml \
         >>$LOG_DIR/mysql_node.stdout.log \
         2>>$LOG_DIR/mysql_node.stderr.log

    ;;

  stop)
    kill_and_wait $PIDFILE 60

    ;;

  *)
    echo "Usage: mysql_node_ctl {start|stop}"

    ;;

esac

