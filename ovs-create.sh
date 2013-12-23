#!/bin/bash -x

ovs-vsctl add-br br0 \
 -- set bridge br0 protocols=OpenFlow10,OpenFlow12,OpenFlow13 \
 -- set bridge br0 other_config:disable-in-band=true \
 -- set bridge br0 other_config:hwaddr=02:fd:ee:8e:0a:44 \
 -- set bridge br0 other_config:datapath-id=000002fdee8e0a44 \
 -- set-fail-mode br0 standalone \
 -- set-controller br0 tcp:127.0.0.1:6633

ovs-vsctl show
ovs-ofctl show br0
