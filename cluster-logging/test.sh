#!/usr/bin/env bash

#function to read properties from quick-start.properties
function getprop {
    grep "${1}" quick-start.properties|cut -d'=' -f2
}

#check all the daemonsets are running
output="$(kubectl get ds fluentd --namespace logging -o=custom-columns=numberUnavailable:status.numberUnavailable)";
numberUnavailable=`echo $output | cut -d' ' -f2-`
echo $numberUnavailable
if [ $numberUnavailable -eq 0 ]; then
    echo Logging daemonsets are running as expected
else
    echo Logging daemonsets are not running as expected
    echo TEST FAILED.......
    #exit 0
fi

#deploy a busybox pod and check that the logs are being collected as expected
kubectl apply -f ./cluster-logging/test/write-logs.yaml
sleep 10

output=`kubectl logs k8s-quickstart-log-checker | tail -n 1`
logentry=`echo $output | cut -d' ' -f2-`
echo $logentry
if [ "$logentry" == "kubernetes quick start log checker" ]; then
    echo Logging test pod logging entries as expected
else
    echo Logging test pod not logging entries as expected
    echo TEST FAILED.......
    #exit 0
fi

#check the logs are in Cloudwatch logs
output=`aws logs describe-log-streams --log-group-name $(getprop 'k8s.clustername').logs --max-items 1`
aws logs get-log-events --log-group-name $(getprop 'k8s.clustername').logs --log-stream-name $output --limit 1