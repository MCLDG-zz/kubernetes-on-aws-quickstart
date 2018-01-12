#!/usr/bin/env bash

#function to read properties from quick-start.properties
function getprop {
    grep "${1}" quick-start.properties|cut -d'=' -f2
}

region=$(getprop 'aws.region')
clustername=$(getprop 'k8s.clustername').cluster.k8s.local
asgname=nodes.${clustername}
echo your region is ${region}
echo your cluster name is ${clustername}

#Scaling - check the desired size of your worker node auto scaling group
beforedesiredsize=`aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $asgname --region $region | jq .AutoScalingGroups[0].DesiredCapacity`
echo size of your worker node auto scaling group before scaling is: $beforedesiredsize

#deploy a pod that will use more capacity than is available. This will cause the cluster worker nodes to scale
echo deploying a pod that will use more capacity than is available. This will cause the cluster worker nodes to scale
kubectl apply -f ./cluster-scaling/templates/dummy-resource-offers.yaml

#Scaling - check the desired size of your worker node auto scaling group
afterdesiredsize=`aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $asgname --region $region | jq '.AutoScalingGroups[0].DesiredCapacity'`
echo size of your worker node auto scaling group after scaling is: $afterdesiredsize

#this checks the size of the ASG. It should be equivalent to check the maxsize in 'kops edit ig nodes'
while [ $beforedesiredsize -eq $afterdesiredsize ]; do
    echo the worker nodes ASG has not yet scaled. Waiting for it to scale out...
    afterdesiredsize=`aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $asgname --region $region | jq '.AutoScalingGroups[0].DesiredCapacity'`
    sleep 10
done

#here we check that the number of instances matches the desired size of the ASG
noinstances=`aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $asgname --region $region | jq '.AutoScalingGroups[0].Instances | length'`
echo number of worker node instances in auto scaling group after scaling is: $noinstances

while [ $noinstances -ne $afterdesiredsize ]; do
    noinstances=`aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $asgname --region $region | jq '.AutoScalingGroups[0].Instances | length'`
    echo number of worker node instances in auto scaling group after scaling is: $noinstances
    echo number of EC2 in the ASG does NOT matches the desired size. Waiting for ASG to scale out...
done

echo the worker nodes ASG has scaled. Auto-scaling is working.
