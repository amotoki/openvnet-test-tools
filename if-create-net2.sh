#!/bin/bash -x

BRNAME=br0

MAC3=52:54:00:0d:84:03
MAC4=52:54:00:0d:84:04

# 172.16.2.0/24
IP3=172.16.2.3
IP4=172.16.2.4

for i in 3 4; do
  ip netns add ns$i
  ip link add if-veth$i type veth peer name ns-veth$i
  ip link set ns-veth$i netns ns$i
done

ip netns exec ns3 ip link set ns-veth3 address $MAC3
ip netns exec ns4 ip link set ns-veth4 address $MAC4

ip netns exec ns3 ifconfig ns-veth3 $IP3 netmask 255.255.255.0
ip netns exec ns4 ifconfig ns-veth4 $IP4 netmask 255.255.255.0

for i in  3 4; do
  ip netns exec ns$i ifconfig lo up
  ip netns exec ns$i ifconfig ns-veth$i up
  ifconfig if-veth$i up
  ovs-vsctl add-port $BRNAME if-veth$i
done
