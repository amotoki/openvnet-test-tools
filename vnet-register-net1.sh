#!/bin/bash

unset http_proxy
unset https_proxy

BRNAME=br0

MAC1=52:54:00:0d:84:01
MAC2=52:54:00:0d:84:02

# 172.16.1.0/24
IP1=172.16.1.1
IP2=172.16.1.2

RUBY_PATH=/opt/axsh/wakame-vnet/ruby/bin
export PATH=$RUBY_PATH:$PATH

cd /opt/axsh/wakame-vnet/vnctl/bin

# network
./vnctl network add --uuid nw-net1 --display-name=net1 --ipv4-network 172.16.1.0 --ipv4-prefix=24 --domain-name=dom1 --network-mode=virtual

# Add network to datapath
./vnctl datapath networks add dp-$BRNAME nw-net1 --broadcast-mac-address=08:00:27:10:03:01

# interface
./vnctl interface add --uuid=if-veth1 --ipv4-address=$IP1 --network-uuid=nw-net1 --mac-address=$MAC1
./vnctl interface add --uuid=if-veth2 --ipv4-address=$IP2 --network-uuid=nw-net1 --mac-address=$MAC2
