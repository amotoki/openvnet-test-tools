#!/bin/bash -x

cd $(dirname $0)

./if-create-net1.sh
./if-create-net2.sh
./if-create-net3.sh
./if-route.sh
