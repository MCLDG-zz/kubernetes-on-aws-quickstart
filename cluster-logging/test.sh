#!/usr/bin/env bash

#function to read properties from quick-start.properties
function getprop {
    grep "${1}" quick-start.properties|cut -d'=' -f2
}

region=$(getprop 'aws.region')
loggroup=$(getprop 'k8s.clustername')-logs
echo your region is ${region}
echo your loggroup is ${loggroup}

#sleep to allow time for the pods to change to 'running' status
echo sleeping for 30s to allow pods to start
sleep 30

#check all the daemonsets are running
output="$(kubectl get ds fluentd --namespace logging -o=custom-columns=numberUnavailable:status.numberUnavailable)";
numberUnavailable=`echo $output | cut -d' ' -f2-`
echo $numberUnavailable
if [ $numberUnavailable == '<none>' ]; then
    echo Logging daemonsets are running as expected
else
    echo Logging daemonsets are not running as expected
    echo TEST FAILED.......
    #exit 0
fi

#deploy a busybox pod and check that the logs are being collected as expected
kubectl apply -f ./cluster-logging/test/write-logs.yaml
echo sleeping for 10s to allow test pod to start
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
output=`aws logs describe-log-streams --log-group-name $loggroup --max-items 1 --region $region`
echo log stream name $(echo "${output}" | jq -r '.logStreams[] | "\(.logStreamName)"')
events=`aws logs get-log-events --log-group-name $loggroup --log-stream-name $(echo "${output}" | jq -r '.logStreams[] | "\(.logStreamName)"') --region $region --limit 10`
event=$(echo "${events}" | jq -r '.events[] | "\(.message)"')
echo event is $event
echo ${event} | grep --quiet "kubernetes quick start log checker"

if [ $? = 1 ]; then
    echo Logging entries could NOT be found in your CloudWatch log group. This indicates logging to CloudWatch is NOT working. Check the AWS CloudWatch console for log group $loggroup
else
    echo Logging entries were found in your CloudWatch log group. This indicates logging to CloudWatch is working correctly. You can view the log entires in the AWS CloudWatch console for log group $loggroup
fi
