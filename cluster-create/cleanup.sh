#!/usr/bin/env bash

#function to read properties from quick-start.properties
function getprop {
    grep "${1}" quick-start.properties|cut -d'=' -f2
}

export KOPS_STATE_STORE=s3://$(getprop 's3.bucketname')

#delete the K8s cluster
kops delete cluster $(getprop 'k8s.clustername').cluster.k8s.local --yes