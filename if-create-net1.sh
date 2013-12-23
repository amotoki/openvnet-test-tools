#!/bin/bash -x

BRNAME=br0

MAC1=52:54:00:0d:84:01
MAC2=52:54:00:0d:84:02

# 172.16.1.0/24
IP1=172.16.1.1
IP2=172.16.1.2

for i in 1 2; do
  ip netns add ns$i
  ip link add if-veth$i type veth peer name ns-veth$i
  ip link set ns-veth$i netns ns$i
done

ip netns exec ns1 ip link set ns-veth1 address $MAC1
ip netns exec ns2 ip link set ns-veth2 address $MAC2

ip netns exec ns1 ifconfig ns-veth1 $IP1 netmask 255.255.255.0
ip netns exec ns2 ifconfig ns-veth2 $IP2 netmask 255.255.255.0

for i in 1 2; do
  ip netns exec ns$i ifconfig lo up
  ip netns exec ns$i ifconfig ns-veth$i up
  ifconfig if-veth$i up
  ovs-vsctl add-port $BRNAME if-veth$i
done
