#!/bin/bash

unset http_proxy
unset https_proxy

HOST=vnet3
HOST_IP=192.168.122.207

BRNAME=br0
DPID=0x000002fdee8e0a44

MAC3=52:54:00:0d:84:03
MAC4=52:54:00:0d:84:04

# 172.16.2.0/24
IP3=172.16.2.3
IP4=172.16.2.4

RUBY_PATH=/opt/axsh/wakame-vnet/ruby/bin
export PATH=$RUBY_PATH:$PATH

cd /opt/axsh/wakame-vnet/vnctl/bin

# network
./vnctl network add --uuid nw-net2 --display-name=net2 --ipv4-network 172.16.2.0 --ipv4-prefix=24 --domain-name=dom1 --network-mode=virtual

# datapath (already registered in vnet-register-net1.sh)
#./vnctl datapath add --uuid dp-$BRNAME --display-name=$BRNAME --dc-segment-id=seg1 --node-id=$HOST --dpid=$DPID --ipv4-address=$HOST_IP

# Add network to datapath
./vnctl datapath networks add dp-$BRNAME nw-net2 --broadcast-mac-address=08:00:27:10:03:02

# interface
./vnctl interface add --uuid=if-veth3 --ipv4-address=$IP3 --network-uuid=nw-net2 --mac-address=$MAC3
./vnctl interface add --uuid=if-veth4 --ipv4-address=$IP4 --network-uuid=nw-net2 --mac-address=$MAC4
