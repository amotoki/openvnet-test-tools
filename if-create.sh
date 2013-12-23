#!/bin/bash -x

BRNAME=br0
DPID=0x000002fdee8e0a4

MAC1=52:54:00:0d:84:01
MAC2=52:54:00:0d:84:02
MAC3=52:54:00:0d:84:03
MAC4=52:54:00:0d:84:04
MAC5=52:54:00:0d:84:05
MAC6=52:54:00:0d:84:06

# 172.16.1.0/24
IP1=172.16.1.1
IP2=172.16.1.2
# 172.16.2.0/24
IP3=172.16.2.3
IP4=172.16.2.4
# 172.16.1.0/24
IP5=172.16.1.1
IP6=172.16.1.2

for i in `seq 6`; do
  ip netns add ns$i
  ip link add if-veth$i type veth peer name ns-veth$i
  ip link set ns-veth$i netns ns$i
done

ip netns exec ns1 ip link set ns-veth1 address $MAC1
ip netns exec ns2 ip link set ns-veth2 address $MAC2
ip netns exec ns3 ip link set ns-veth3 address $MAC3
ip netns exec ns4 ip link set ns-veth4 address $MAC4
ip netns exec ns5 ip link set ns-veth5 address $MAC5
ip netns exec ns6 ip link set ns-veth6 address $MAC6

ip netns exec ns1 ifconfig ns-veth1 $IP1 netmask 255.255.255.0
ip netns exec ns2 ifconfig ns-veth2 $IP2 netmask 255.255.255.0
ip netns exec ns3 ifconfig ns-veth3 $IP3 netmask 255.255.255.0
ip netns exec ns4 ifconfig ns-veth4 $IP4 netmask 255.255.255.0
ip netns exec ns5 ifconfig ns-veth5 $IP5 netmask 255.255.255.0
ip netns exec ns6 ifconfig ns-veth6 $IP6 netmask 255.255.255.0

for i in `seq 6`; do
  ip netns exec ns$i ifconfig lo up
  ip netns exec ns$i ifconfig ns-veth$i up
  ifconfig if-veth$i up
  ovs-vsctl add-port $BRNAME if-veth$i
done

# Set route between 172.16.1.0/24 and 172.16.2.0/24
for ns in ns1 ns2; do
  ip netns exec $ns route add -net 172.16.2.0 netmask 255.255.255.0 gw 172.16.1.254
done
for ns in ns3 ns4; do
  ip netns exec $ns route add -net 172.16.1.0 netmask 255.255.255.0 gw 172.16.2.254
done
