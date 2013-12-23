#!/bin/bash

RUBY_PATH=/opt/axsh/wakame-vnet/ruby/bin
export PATH=$RUBY_PATH:$PATH

VNCTL_DIR=/opt/axsh/wakame-vnet/vnctl

cd $VNCTL_DIR
ovs-ofctl dump-flows br0 | ./bin/vnflows
