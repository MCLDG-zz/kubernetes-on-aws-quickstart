#!/usr/bin/env bash

#function to read properties from quick-start.properties
function getprop {
    grep "${1}" quick-start.properties|cut -d'=' -f2
}

./cluster-logging/cleanup.sh
./cluster-monitoring/cleanup.sh
./cluster-scaling/cleanup.sh
./cicd/cleanup.sh
./ingress-controllers/cleanup.sh
./secrets/cleanup.sh
./service-mesh/cleanup.sh
./distributed-tracing/cleanup.sh
./network-policy/cleanup.sh