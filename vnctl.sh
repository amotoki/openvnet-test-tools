#!/bin/bash

DO_FORMAT=True

RUBY_PATH=/opt/axsh/wakame-vnet/ruby/bin
export PATH=$RUBY_PATH:$PATH

VNCTL_DIR=/opt/axsh/wakame-vnet/vnctl
VNCTL_BIN=./bin/vnctl

if [ "$DO_FORMAT" == "True" ]; then
  SCRIPTDIR=`pwd`/`dirname $0`
  FORMATTER=$SCRIPTDIR/format.rb
else
  FORMATTER=cat
fi

cd $VNCTL_DIR
./$VNCTL_BIN $* | $FORMATTER
