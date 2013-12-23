#!/bin/bash -x

# Set route between 172.16.1.0/24 and 172.16.2.0/24
for ns in ns1 ns2; do
  ip netns exec $ns route add -net 172.16.2.0 netmask 255.255.255.0 gw 172.16.1.254
done
for ns in ns3 ns4; do
  ip netns exec $ns route add -net 172.16.1.0 netmask 255.255.255.0 gw 172.16.2.254
done
