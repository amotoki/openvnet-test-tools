#!/bin/bash

MODE=$1

RUBY_PATH=/opt/axsh/wakame-vnet/ruby/bin
export PATH=$RUBY_PATH:$PATH

function start() {
  initctl start vnet-vnmgr
  initctl start vnet-webapi
  initctl start vnet-vna
}

function stop() {
  initctl stop vnet-vnmgr
  initctl stop vnet-webapi
  initctl stop vnet-vna
}

function dbclear() {
  mysql -uroot -e 'DROP DATABASE vnet;'
  mysql -uroot -e 'CREATE DATABASE vnet;'
  cd /opt/axsh/wakame-vnet/vnet
  bundle exec rake db:init
  mysql -uroot -e 'SHOW TABLES;' vnet
}

function logclear() {
  rm /var/log/wakame-vnet/*
}

function status() {
  initctl status vnet-vnmgr
  initctl status vnet-webapi
  initctl status vnet-vna
}

case "$MODE" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    stop
    start
    ;;
  status)
    status
    ;;
  resetdb)
    stop
    dbclear
    logclear
    start
    ;;
  *)
    echo "Usage: $0 (start|stop|status|restart|resetdb)"
    ;;
esac
