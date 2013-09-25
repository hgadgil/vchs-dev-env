#!/bin/bash

source ./base.sh

MYSQL55_PKG_DIR=$PKG_DIR_BASE/mysql55
MYSQLCLIENT_PKG_DIR=$PKG_DIR_BASE/mysqlclient

MYSQL_TMP_DIR=$TMP_DIR_BASE/mysql55
MYSQL_STORE_DIR=$STORE_DIR_BASE/mysql55

mkdir -p $MYSQL55_PKG_DIR
mkdir -p $MYSQLCLIENT_PKG_DIR
mkdir -p $MYSQL_TMP_DIR
mkdir -p $MYSQL_STORE_DIR

# download mysql server & client
if [ ! -f $DOWNLOAD_DIR/server-5.5.29-rel29.4-401.Linux.x86_64.tar.gz ]; then
    cd $DOWNLOAD_DIR
    wget http://blob.cfblob.com/rest/objects/4e4e78bca11e122004e4e8ec6484310510b21c863a27 \
      -O $DOWNLOAD_DIR/server-5.5.29-rel29.4-401.Linux.x86_64.tar.gz

    tar xfvz server-5.5.29-rel29.4-401.Linux.x86_64.tar.gz
fi

if [ ! -f $DOWNLOAD_DIR/initdb-5.5.29-rel29.4-401.Linux.x86_64.tar.gz ]; then
    cd $DOWNLOAD_DIR
    wget http://blob.cfblob.com/rest/objects/4e4e78bca11e122204e4e98638b7630510b21d03bb63 \
      -O $DOWNLOAD_DIR/initdb-5.5.29-rel29.4-401.Linux.x86_64.tar.gz

    tar xfvz initdb-5.5.29-rel29.4-401.Linux.x86_64.tar.gz
fi

if [ ! -f $DOWNLOAD_DIR/client-5.5.29-rel29.4-401.Linux.x86_64.tar.gz ]; then
    cd $DOWNLOAD_DIR
    wget http://blob.cfblob.com/rest/objects/4e4e78bca41e121004e4e7d517618f0510b21d28a2bb \
      -O $DOWNLOAD_DIR/client-5.5.29-rel29.4-401.Linux.x86_64.tar.gz

    tar xfvz client-5.5.29-rel29.4-401.Linux.x86_64.tar.gz
fi

cd $DOWNLOAD_DIR/server-5.5.29-rel29.4-401.Linux.x86_64
for x in bin include lib libexec share; do
  cp -a $x $MYSQL55_PKG_DIR
done

cp -a $DOWNLOAD_DIR/initdb55 $MYSQL55_PKG_DIR

cp -v $VCAP_HOME/scripts/mysql55.server $MYSQL55_PKG_DIR/libexec/mysql.server
chmod +x $MYSQL55_PKG_DIR/libexec/mysql.server

cd $DOWNLOAD_DIR/client-5.5.29-rel29.4-401.Linux.x86_64
for x in bin include lib; do
  cp -a $x $MYSQLCLIENT_PKG_DIR
done

mkdir -p $STORE_DIR_BASE/mysql_node
mkdir -p $RUN_DIR_BASE/mysqld

# Setup SQL Lite
if [ ! -f $DOWNLOAD_DIR/sqlite-autoconf-3070500.tar.gz ]; then
    cd $DOWNLOAD_DIR
    wget http://blob.cfblob.com/rest/objects/4e4e78bca11e121004e4e7d511f82104f3068661ccfa \
      -O $DOWNLOAD_DIR/sqlite-autoconf-3070500.tar.gz

    tar xzf sqlite-autoconf-3070500.tar.gz
    (
      cd sqlite-autoconf-3070500
      ./configure --prefix=$PKG_DIR_BASE/sqlite
      make
      make install
    )
fi

# Setup mysql service

cd $INSTALL_DIR/cf-services-release/src/mysql_service
bundle config build.do_sqlite3 --with-sqlite3-dir=$PKG_DIR_BASE/sqlite
bundle config build.mysql2 --with-mysql-dir=$MYSQLCLIENT_PKG_DIR --with-mysql-include=$MYSQLCLIENT_PKG_DIR/include/mysql
bundle config build.do_mysql --with-mysql-dir=$MYSQLCLIENT_PKG_DIR --with-mysql-include=$MYSQLCLIENT_PKG_DIR/include/mysql
bundle install --local --deployment



