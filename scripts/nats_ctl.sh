#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $DIR/base.sh

RUN_DIR=$RUN_DIR_BASE/nats
LOG_DIR=$LOG_DIR_BASE/nats

PIDFILE=$RUN_DIR/nats.pid

case $1 in

  start)
    pid_guard $PIDFILE "NATS"

    make_dir $RUN_DIR
    make_dir $LOG_DIR

    echo $$ > $PIDFILE

    exec $RUBY_HOME/bin/ruby $SCRIPTS_DIR/nats-server-runner.rb \
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
