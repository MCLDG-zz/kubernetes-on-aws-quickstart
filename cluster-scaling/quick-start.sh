#!/usr/bin/env bash

#Scaling - check the size of your worker node auto scaling group
echo checking the size of your worker node auto scaling group
maxsize=`aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names nodes.cluster.k8s.local | jq .AutoScalingGroups[0].MaxSize`

if [ $maxsize -eq 2 ]; then
    echo the value of `MaxSize` is 2, which means you can't scale beyond 2 worker nodes. Use Kops to update your maximum cluster size
    echo run the command `kops edit ig nodes`, change the maxSize to a value greater than 2, save the file, then run `kops update cluster --name <your cluster name> --yes`
else
    echo your cluster size is $maxsize, which is fine
fi

#need to figure out a way to update the Kops config, to increase worker node ASG size, and also to
#update the IAM policy for the worker nodes - required to allow autoscaling

#check that the scaling component is working correctly
./cluster-scaling/test.sh
