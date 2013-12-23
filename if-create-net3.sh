#!/bin/bash -x

BRNAME=br0

MAC5=52:54:00:0d:84:05
MAC6=52:54:00:0d:84:06

# 172.16.1.0/24
IP5=172.16.1.1
IP6=172.16.1.2

for i in 5 6; do
  ip netns add ns$i
  ip link add if-veth$i type veth peer name ns-veth$i
  ip link set ns-veth$i netns ns$i
done

ip netns exec ns5 ip link set ns-veth5 address $MAC5
ip netns exec ns6 ip link set ns-veth6 address $MAC6

ip netns exec ns5 ifconfig ns-veth5 $IP5 netmask 255.255.255.0
ip netns exec ns6 ifconfig ns-veth6 $IP6 netmask 255.255.255.0

for i in 5 6; do
  ip netns exec ns$i ifconfig lo up
  ip netns exec ns$i ifconfig ns-veth$i up
  ifconfig if-veth$i up
  ovs-vsctl add-port $BRNAME if-veth$i
done
