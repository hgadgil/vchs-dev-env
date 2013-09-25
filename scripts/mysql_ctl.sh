#!/bin/bash

source ./base.sh

case $1 in

  start)
    $PKG_DIR_BASE/mysql55/libexec/mysql.server start $CFG_DIR_BASE/my55.cnf

    ;;

  stop)
    $PKG_DIR_BASE/mysql55/libexec/mysql.server stop $JOB_DIR_BASE/my55.cnf

    ;;

  *)
    echo "Usage: mysql_ctl {start|stop}"

    ;;

esac

