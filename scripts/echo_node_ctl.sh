#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $DIR/base.sh

RUN_DIR=$RUN_DIR_BASE/echo_node
LOG_DIR=$LOG_DIR_BASE/echo_node

PIDFILE=$RUN_DIR/echo_node.pid

case $1 in

  start)
    pid_guard $PIDFILE "Echo node"

    make_dir $RUN_DIR
    make_dir $LOG_DIR

    echo $$ > $PIDFILE

    exec $INSTALL_DIR/echo/bin/echo_node \
         -c $CFG_DIR_BASE/echo_node.yml \
         >>$LOG_DIR/echo_node.stdout.log \
         2>>$LOG_DIR/echo_node.stderr.log

    ;;

  stop)
    kill_and_wait $PIDFILE 60

    ;;

  *)
    echo "Usage: echo_node_ctl {start|stop}"

    ;;

esac

