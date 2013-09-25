#!/bin/bash

source ./base.sh

RUN_DIR=$RUN_DIR_BASE/nats
LOG_DIR=$LOG_DIR_BASE/nats

PIDFILE=$RUN_DIR/nats.pid

case $1 in

  start)
    pid_guard $PIDFILE "NATS"

    mkdir -p $RUN_DIR
    mkdir -p $LOG_DIR

    echo $$ > $PIDFILE

    exec $INSTALL_DIR/nats/bin/nats-server \
         -c $CFG_DIR_BASE/nats.yml \
         >>$LOG_DIR/nats.stdout.log \
         2>>$LOG_DIR/nats.stderr.log

    ;;

  stop)
    kill_and_wait $PIDFILE

    ;;

  *)
    echo "Usage: nats_ctl {start|stop}"

    ;;

esac
