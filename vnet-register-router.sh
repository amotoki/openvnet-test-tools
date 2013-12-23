#!/bin/bash -x

unset http_proxy
unset https_proxy

HOST=vnet3
HOST_IP=192.168.122.207

webapi_host='localhost'
port='9090'

BRNAME=br0

# 172.16.1.0/24
IP1=172.16.1.1
IP2=172.16.1.2
IP_GW1=172.16.1.254
# 172.16.2.0/24
IP3=172.16.2.3
IP4=172.16.2.4
IP_GW2=172.16.2.254

RUBY_PATH=/opt/axsh/wakame-vnet/ruby/bin
export PATH=$RUBY_PATH:$PATH

cd /opt/axsh/wakame-vnet/vnctl/bin

#-----------------------------------------------------------
#./vnctl interface add --uuid=if-vnet1gw --network-uuid=nw-net1 --mac-address=52:54:00:74:00:00 --ipv4-address=$IP_GW1 --mode=simulated
curl -s -X POST --data-urlencode uuid=if-vnet1gw --data-urlencode network_uuid=nw-net1 \
--data-urlencode mac_address=52:54:00:74:00:00 --data-urlencode ipv4_address=$IP_GW1 --data-urlencode mode=simulated \
http://${webapi_host}:${port}/api/interfaces

./vnctl network_service add --uuid=ns-vnet1gw --interface-uuid=if-vnet1gw --display-name=router

#./vnctl interface add --uuid=if-vnet2gw --network-uuid=nw-net2 --mac-address=52:54:00:74:22:22 --ipv4-address=$IP_GW2 --mode=simulated
curl -s -X POST --data-urlencode uuid=if-vnet2gw --data-urlencode network_uuid=nw-net2 \
--data-urlencode mac_address=52:54:00:74:22:22 --data-urlencode ipv4_address=$IP_GW2 --data-urlencode mode=simulated \
http://${webapi_host}:${port}/api/interfaces

./vnctl network_service add --uuid=ns-vnet2gw --interface-uuid=if-vnet2gw --display-name=router

# router
./vnctl route_link add --uuid=rl-vnetlink1 --mac-address=52:54:00:60:11:11
#./vnctl datapath route_links add dp-$BRNAME rl-vnetlink1 --link-mac-address=08:00:27:20:01:01
curl -s -X POST --data-urlencode route_link_uuid=rl-vnetlink1 \
  --data-urlencode mac_address=08:00:27:20:01:01 \
  http://${webapi_host}:${port}/api/datapaths/dp-$BRNAME/route_links/rl-vnetlink1

#./vnctl route add --uuid=r-vnet1 --interface-uuid=if-vnet1gw --route-link-uuid=rl-vnetlink1 --ipv4-address=172.16.1.0 --ipv4-prefix=24
curl -s -X POST --data-urlencode uuid=r-vnet1 --data-urlencode interface_uuid=if-vnet1gw --data-urlencode route_link_uuid=rl-vnetlink1 --data-urlencode ipv4_network=172.16.1.0 http://${webapi_host}:${port}/api/routes
#./vnctl route add --uuid=r-vnet2 --interface-uuid=if-vnet2gw --route-link-uuid=rl-vnetlink1 --ipv4-address=172.16.2.0 --ipv4-prefix=24
curl -s -X POST --data-urlencode uuid=r-vnet2 --data-urlencode interface_uuid=if-vnet2gw --data-urlencode route_link_uuid=rl-vnetlink1 --data-urlencode ipv4_network=172.16.2.0 http://${webapi_host}:${port}/api/routes

echo
