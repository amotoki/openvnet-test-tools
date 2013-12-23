#!/bin/bash -x

BRNAME=br0

for i in `seq 6`; do
  ovs-vsctl del-port $BRNAME if-veth$i
  ip link delete if-veth$i
  ip netns delete ns$i
done
