#!/bin/sh

set -e

apt-get update -y --fix-missing
apt-get install -y build-essential curl git-core libcurl4-gnutls-dev libmysqlclient-dev libaio1 nodejs

