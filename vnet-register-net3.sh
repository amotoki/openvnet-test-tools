#!/bin/bash

unset http_proxy
unset https_proxy

HOST=vnet3
HOST_IP=192.168.122.207

BRNAME=br0
DPID=0x000002fdee8e0a44

MAC5=52:54:00:0d:84:05
MAC6=52:54:00:0d:84:06

# 172.16.1.0/24
IP1=172.16.1.1
IP2=172.16.1.2

RUBY_PATH=/opt/axsh/wakame-vnet/ruby/bin
export PATH=$RUBY_PATH:$PATH

cd /opt/axsh/wakame-vnet/vnctl/bin

# network
./vnctl network add --uuid nw-net3 --display-name=net3 --ipv4-network 172.16.1.0 --ipv4-prefix=24 --domain-name=dom2 --network-mode=virtual

# datapath (already registered in vnet-register-net1.sh)
#./vnctl datapath add --uuid dp-$BRNAME --display-name=$BRNAME --dc-segment-id=seg1 --node-id=$HOST --dpid=$DPID --ipv4-address=$HOST_IP

# Add network to datapath
./vnctl datapath networks add dp-$BRNAME nw-net3 --broadcast-mac-address=08:00:27:10:03:03

# interface
./vnctl interface add --uuid=if-veth5 --ipv4-address=$IP1 --network-uuid=nw-net3 --mac-address=$MAC5
./vnctl interface add --uuid=if-veth6 --ipv4-address=$IP2 --network-uuid=nw-net3 --mac-address=$MAC6
