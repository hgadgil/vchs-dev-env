#!/bin/sh

source ./base.sh

MY_LD_FILE=/etc/ld.so.conf.d/mysql.conf

rm $MY_LD_FILE

echo "$PKG_DIR_BASE/mysqlclient/lib/mysql" > $MY_LD_FILE
echo "$PKG_DIR_BASE/mysql/lib/mysql" >> $MY_LD_FILE

/sbin/ldconfig
