#!/bin/bash

unset http_proxy
unset https_proxy

HOST=vnet3
HOST_IP=192.168.122.207

BRNAME=br0
DPID=0x000002fdee8e0a44

RUBY_PATH=/opt/axsh/wakame-vnet/ruby/bin
export PATH=$RUBY_PATH:$PATH

cd /opt/axsh/wakame-vnet/vnctl/bin

# datapath
./vnctl datapath add --uuid dp-$BRNAME --display-name=$BRNAME --dc-segment-id=seg1 --node-id=$HOST --dpid=$DPID --ipv4-address=$HOST_IP
