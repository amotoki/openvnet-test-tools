# OpenVNet test tools with network namespace

## Tested Environment

* CentOS 6.5
* kernel-2.6.32-431.1.2.0.1.el6.x86_64 (CentOS 6.5 latest)

## Network Namespace
In CentOS 6.x, network namespace is not supported, so we need to
additional packages to use network namespace.
OpenStack RDO provides network namespace aware kernel and iproute.

### CentOS 6.5
In CentOS 6.5, kernel itself supports network namespace, but iproute
does not support network namespace (no "netns" subcommand).

The following commands setup OpenStack RDO release repository to /etc/yum.repos.d
and "yum update" installs a new version of iproute (which supports network namespace),
```
# yum install http://rdo.fedorapeople.org/rdo-release.rpm
# yum install iproute
```
or you can install iproute package explicitly.
```
# yum install yum install http://rdo.fedorapeople.org/rdo-release.rpm
```

After the installation, check the appropriate iproute package is installed and it works.
```
# rpm -qa | grep iproute
iproute-2.6.32-130.el6ost.netns.2.x86_64
# ip netns
# ip netns add testns1
# ip netns
testns1
# ip netns delete testns1
```

### CentOS 6.4 or older
I have not tested these version, but ROD provides network namespace aware kernel.
The packages are available at:
http://repos.fedorapeople.org/repos/openstack/openstack-havana/epel-6/

## How to run

### Install OpenVNet
Follow OpenVNet install guide: https://github.com/axsh/openvnet/blob/master/InstallGuide.md
No need to go "Let's try 1Box OpenVNet" section.

Make sure to start redis before starting OpenVNet services:
```
# chkconfig redis on
# service redis start
```

### Try OpenVNet with network namespaces

Register various OpenVNet resources.
```
# ./vnet-register-network.sh
# ./vnet-register-router.sh
```

* vnet-register-network.sh : Create three virtual networks
  * net1 : 172.16.1.0/24
  * net2 : 172.16.2.0/24
  * net3 : 172.16.1.0/24 (IP address range is overlaped with net1)
* vnet-register-router.sh
  * Create a router between net1 and net2

Setup OVS datapath and create interfaces connected to OVS bridge
```
# ./ovs-create.sh
# ./if-create.sh
```

After running the above scripts, you can see the following.
You can see 6 network namespaces and 6 veth interfaces are connected to OVS bridge br0.
OVS bridge br0 is connected to OpenVNet agent (vnet-vna) with OpenFlow protocol (```is_conncted: true```).
```
# ip netns
ns5
ns2
ns6
ns4
ns3
ns1
# ip -o link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN \    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000\    link/ether 52:54:00:fd:9f:45 brd ff:ff:ff:ff:ff:ff
4: ovs-system: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN \    link/ether 4e:5e:dd:a0:1a:fe brd ff:ff:ff:ff:ff:ff
124: br0: <BROADCAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN \    link/ether 02:fd:ee:8e:0a:44 brd ff:ff:ff:ff:ff:ff
127: if-veth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000\    link/ether 1a:42:f4:d5:d4:77 brd ff:ff:ff:ff:ff:ff
130: if-veth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000\    link/ether b2:d3:e4:dc:df:f1 brd ff:ff:ff:ff:ff:ff
133: if-veth3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000\    link/ether c6:3f:5d:4b:b1:38 brd ff:ff:ff:ff:ff:ff
136: if-veth4: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000\    link/ether ce:50:9d:28:81:81 brd ff:ff:ff:ff:ff:ff
139: if-veth5: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000\    link/ether 2a:c0:e2:e8:29:94 brd ff:ff:ff:ff:ff:ff
142: if-veth6: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000\    link/ether b2:9c:63:8a:d8:c8 brd ff:ff:ff:ff:ff:ff
# ovs-vsctl show
73ab1cf2-5964-40d4-9dfe-eb96407fafd2
    Bridge "br0"
        Controller "tcp:127.0.0.1:6633"
            is_connected: true
        fail_mode: standalone
        Port "if-veth4"
            Interface "if-veth4"
        Port "if-veth6"
            Interface "if-veth6"
        Port "if-veth1"
            Interface "if-veth1"
        Port "if-veth2"
            Interface "if-veth2"
        Port "if-veth5"
            Interface "if-veth5"
        Port "br0"
            Interface "br0"
                type: internal
        Port "if-veth3"
            Interface "if-veth3"
    ovs_version: "1.11.0"
```

### Check network connectivity

* net1

```
# ip netns exec ns1 ip -o addr
125: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN \    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
125: lo    inet 127.0.0.1/8 scope host lo
125: lo    inet6 ::1/128 scope host \       valid_lft forever preferred_lft forever
126: ns-veth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000\    link/ether 52:54:00:0d:84:01 brd ff:ff:ff:ff:ff:ff
126: ns-veth1    inet 172.16.1.1/24 brd 172.16.1.255 scope global ns-veth1
126: ns-veth1    inet6 fe80::5054:ff:fe0d:8401/64 scope link \       valid_lft forever preferred_lft forever
# ip netns exec ns2 ip -o addr
128: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN \    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
128: lo    inet 127.0.0.1/8 scope host lo
128: lo    inet6 ::1/128 scope host \       valid_lft forever preferred_lft forever
129: ns-veth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000\    link/ether 52:54:00:0d:84:02 brd ff:ff:ff:ff:ff:ff
129: ns-veth2    inet 172.16.1.2/24 brd 172.16.1.255 scope global ns-veth2
129: ns-veth2    inet6 fe80::5054:ff:fe0d:8402/64 scope link \       valid_lft forever preferred_lft forever
# ip netns exec ns1 arp -na
# ip netns exec ns1 ping 172.16.1.2
PING 172.16.1.2 (172.16.1.2) 56(84) bytes of data.
64 bytes from 172.16.1.2: icmp_seq=1 ttl=64 time=0.391 ms
64 bytes from 172.16.1.2: icmp_seq=2 ttl=64 time=0.049 ms
64 bytes from 172.16.1.2: icmp_seq=3 ttl=64 time=0.044 ms
^C
--- 172.16.1.2 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2441ms
rtt min/avg/max/mdev = 0.044/0.161/0.391/0.162 ms
# ip netns exec ns1 arp -na
? (172.16.1.2) at 52:54:00:0d:84:02 [ether] on ns-veth1
# ip netns exec ns2 arp -na
? (172.16.1.1) at 52:54:00:0d:84:01 [ether] on ns-veth2
```

* net2

```
# ip netns exec ns3 ip -o addr
131: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN \    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
131: lo    inet 127.0.0.1/8 scope host lo
131: lo    inet6 ::1/128 scope host \       valid_lft forever preferred_lft forever
132: ns-veth3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000\    link/ether 52:54:00:0d:84:03 brd ff:ff:ff:ff:ff:ff
132: ns-veth3    inet 172.16.2.3/24 brd 172.16.2.255 scope global ns-veth3
132: ns-veth3    inet6 fe80::5054:ff:fe0d:8403/64 scope link \       valid_lft forever preferred_lft forever
# ip netns exec ns4 ip -o addr
134: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN \    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
134: lo    inet 127.0.0.1/8 scope host lo
134: lo    inet6 ::1/128 scope host \       valid_lft forever preferred_lft forever
135: ns-veth4: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000\    link/ether 52:54:00:0d:84:04 brd ff:ff:ff:ff:ff:ff
135: ns-veth4    inet 172.16.2.4/24 brd 172.16.2.255 scope global ns-veth4
135: ns-veth4    inet6 fe80::5054:ff:fe0d:8404/64 scope link \       valid_lft forever preferred_lft forever
# ip netns exec ns3 ping 172.16.2.4
PING 172.16.2.4 (172.16.2.4) 56(84) bytes of data.
64 bytes from 172.16.2.4: icmp_seq=1 ttl=64 time=0.713 ms
64 bytes from 172.16.2.4: icmp_seq=2 ttl=64 time=0.086 ms
64 bytes from 172.16.2.4: icmp_seq=3 ttl=64 time=0.058 ms
64 bytes from 172.16.2.4: icmp_seq=4 ttl=64 time=0.041 ms
64 bytes from 172.16.2.4: icmp_seq=5 ttl=64 time=0.045 ms
^[^C
--- 172.16.2.4 ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4219ms
rtt min/avg/max/mdev = 0.041/0.188/0.713/0.263 ms
```

* net3

Before ping from 172.16.1.1 to 172.16.1.2, start tcpdump on interfaces both on net1 and net3.

```
# ip netns exec ns2 tcpdump -i ns-veth2
```
```
# ip netns exec ns6 tcpdump -i ns-veth6
```

Ping from 172.16.1.1 (ns5) to 172.16.1.2 (ns6)
```
# ip netns exec ns5 ping -c 5 172.16.1.2
PING 172.16.1.2 (172.16.1.2) 56(84) bytes of data.
64 bytes from 172.16.1.2: icmp_seq=1 ttl=64 time=0.391 ms
64 bytes from 172.16.1.2: icmp_seq=2 ttl=64 time=0.052 ms
64 bytes from 172.16.1.2: icmp_seq=3 ttl=64 time=0.087 ms
64 bytes from 172.16.1.2: icmp_seq=4 ttl=64 time=0.048 ms
64 bytes from 172.16.1.2: icmp_seq=5 ttl=64 time=0.045 ms

--- 172.16.1.2 ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4000ms
rtt min/avg/max/mdev = 0.045/0.124/0.391/0.134 ms
```

We can see packets in tcpdump on ns6.
```
# ip netns exec ns6 tcpdump -i ns-veth6
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on ns-veth6, link-type EN10MB (Ethernet), capture size 65535 bytes
21:57:40.246563 ARP, Request who-has 172.16.1.2 tell 172.16.1.1, length 28
21:57:40.246581 ARP, Reply 172.16.1.2 is-at 52:54:00:0d:84:06 (oui Unknown), length 28
21:57:40.246646 IP 172.16.1.1 > 172.16.1.2: ICMP echo request, id 22894, seq 1, length 64
21:57:40.246658 IP 172.16.1.2 > 172.16.1.1: ICMP echo reply, id 22894, seq 1, length 64
21:57:41.246538 IP 172.16.1.1 > 172.16.1.2: ICMP echo request, id 22894, seq 2, length 64
21:57:41.246556 IP 172.16.1.2 > 172.16.1.1: ICMP echo reply, id 22894, seq 2, length 64
21:57:42.246522 IP 172.16.1.1 > 172.16.1.2: ICMP echo request, id 22894, seq 3, length 64
21:57:42.246572 IP 172.16.1.2 > 172.16.1.1: ICMP echo reply, id 22894, seq 3, length 64
21:57:43.246516 IP 172.16.1.1 > 172.16.1.2: ICMP echo request, id 22894, seq 4, length 64
21:57:43.246532 IP 172.16.1.2 > 172.16.1.1: ICMP echo reply, id 22894, seq 4, length 64
21:57:44.246490 IP 172.16.1.1 > 172.16.1.2: ICMP echo request, id 22894, seq 5, length 64
21:57:44.246505 IP 172.16.1.2 > 172.16.1.1: ICMP echo reply, id 22894, seq 5, length 64
21:57:45.246479 ARP, Request who-has 172.16.1.1 tell 172.16.1.2, length 28
21:57:45.246678 ARP, Reply 172.16.1.1 is-at 52:54:00:0d:84:05 (oui Unknown), length 28
^C
14 packets captured
14 packets received by filter
0 packets dropped by kernel
```


### Routing between net1 and net2

We need to setup additional route information in each network namespaces.
It is already done by if-create.sh script.

ping from 172.16.1.1 (ns1) to 172.16.2.3 (ns3).
You will see ARP replies from 172.16.2.3 if it works well.

```
# ip netns exec ns1 netstat -nr
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
172.16.2.0      172.16.1.254    255.255.255.0   UG        0 0          0 ns-veth1
172.16.1.0      0.0.0.0         255.255.255.0   U         0 0          0 ns-veth1
# ip netns exec ns3 netstat -nr
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
172.16.2.0      0.0.0.0         255.255.255.0   U         0 0          0 ns-veth3
172.16.1.0      172.16.2.254    255.255.255.0   UG        0 0          0 ns-veth3
# ip netns exec ns1 ping 172.16.2.3
PING 172.16.2.3 (172.16.2.3) 56(84) bytes of data.
64 bytes from 172.16.2.3: icmp_seq=1 ttl=64 time=18.1 ms
64 bytes from 172.16.2.3: icmp_seq=2 ttl=64 time=0.056 ms
64 bytes from 172.16.2.3: icmp_seq=3 ttl=64 time=0.048 ms
^C
--- 172.16.2.3 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2790ms
rtt min/avg/max/mdev = 0.048/6.089/18.163/8.537 ms
# ip netns exec ns1 arp -na
? (172.16.1.254) at 52:54:00:74:00:00 [ether] on ns-veth1
# ip netns exec ns3 arp -na
? (172.16.2.254) at 52:54:00:74:22:22 [ether] on ns-veth3
```

## Utilities

### Reinitialize OpenVNet and network namespaces.

```
# ./if-delete.sh
# ./ovs-delete.sh
# ./vnet-all.sh resetdb
```

"vnet-all.sh resetdb" does the following:
* Stop all openvnet services
* Drop "vnet" database
* Create "vnet" database
* Populate openvnet tables to "vnet" database
* Remove OpenVNet logs in /var/log/wakame-vnet
* Start all openvnet services

### vnctl.sh

It is a wrapper of /opt/axsh/wakame-vnet/vnctl/bin/vnctl.
After running vnctl command, it formats the outputs of vnctl to human-friendly format.
If you want raw output of vnctl, please comment out ```DO_FORMAT=True```.

```
# ./vnctl.sh datapath show
{"id"=>1,
 "uuid"=>"dp-br0",
 "display_name"=>"br0",
 "is_connected"=>false,
 "dpid"=>"0x000002fdee8e0a44",
 "dc_segment_id"=>nil,
 "ipv4_address"=>3232266959,
 "node_id"=>"vnet3",
 "created_at"=>"2013-12-23T13:08:11Z",
 "updated_at"=>"2013-12-23T13:08:11Z",
 "dc_segment"=>nil}
```

### dump-flows.sh

It is a wrapper of /opt/axsh/wakame-vnet/vnctl/bin/vnflows.
OpenVNet installs MANY MANY flow entries to OVS bridge :-) and it helps us to debug flows.

It just runns the following:
```
# ovs-ofctl dump-flows br0 | ./bin/vnflows
```
