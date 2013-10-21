#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $DIR/base.sh

RUN_DIR=$RUN_DIR_BASE/sc
LOG_DIR=$LOG_DIR_BASE/sc

PIDFILE=$RUN_DIR/sc.pid

case $1 in

  start)

   rm -f $INSTALL_DIR/service_controller/tmp/pids/server.pid

   pid_guard $PIDFILE "SERVICE_CONTROLLER"

    make_dir $RUN_DIR
    make_dir $LOG_DIR

    echo $$ > $PIDFILE

    cd $INSTALL_DIR/service_controller
    exec rails server

    ;;

  stop)
    kill_and_wait $PIDFILE

    ;;

  *)
    echo "Usage: sc_ctl {start|stop}"

    ;;

esac
