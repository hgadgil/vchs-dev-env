#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $DIR/base.sh

RUN_DIR=$RUN_DIR_BASE/echo_gateway
LOG_DIR=$LOG_DIR_BASE/echo_gateway

PIDFILE=$RUN_DIR/echo_gateway.pid

case $1 in

  start)
    pid_guard $PIDFILE "Echo gateway"

    make_dir $RUN_DIR
    make_dir $LOG_DIR

    echo $$ > $PIDFILE

    exec $INSTALL_DIR/echo/bin/echo_gateway \
         -c $CFG_DIR_BASE/echo_gateway.yml \
         >>$LOG_DIR/echo_gateway.stdout.log \
         2>>$LOG_DIR/echo_gateway.stderr.log

    ;;

  stop)
    kill_and_wait $PIDFILE

    ;;

  *)
    echo "Usage: echo_gateway_ctl {start|stop}"

    ;;

esac
