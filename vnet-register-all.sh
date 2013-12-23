#!/bin/bash

cd $(dirname $0)

./vnet-register-datapath.sh
./vnet-register-net1.sh
./vnet-register-net2.sh
./vnet-register-net3.sh
./vnet-register-router.sh
