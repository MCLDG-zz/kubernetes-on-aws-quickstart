#!/usr/bin/env bash

#sleep to allow time for the pods to change to 'running' status
echo sleeping for 30s to allow pods to start
sleep 30

#check all the daemonsets are running
output="$(kubectl get ds node-exporter --namespace monitoring -o=custom-columns=numberUnavailable:status.numberUnavailable)";
numberUnavailable=`echo $output | cut -d' ' -f2-`
echo $numberUnavailable
if [ $numberUnavailable == '<none>' ]; then
    echo Monitoring daemonsets are running as expected
else
    echo Monitoring daemonsets are not running as expected
    echo TEST FAILED.......
    #exit 0
fi
