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

#Scaling - check the size of your worker node auto scaling group
echo checking the size of your worker node auto scaling group
maxsize=`aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $asgname --region $region | jq .AutoScalingGroups[0].MaxSize`

#this checks the size of the ASG. It should be equivalent to check the maxsize in 'kops edit ig nodes'
if [ $maxsize -eq 2 ]; then
    echo the value of worker nodes MaxSize is 2, which means you cannot scale beyond 2 worker nodes. I will now update your nodes instance group maxsize

    #update the maxsize of the worker nodes instance group
    echo updating the maxsize of the worker nodes instance group
    kops get ig nodes -o yaml > ignodes.yaml
    config=ignodes.yaml
    sed 's/.*maxSize.*/  maxSize: 10/' ignodes.yaml > ignodesupdated.yaml
    kops replace -f ignodesupdated.yaml
    kops update cluster ${clustername} --yes
    kops rolling-update cluster ${clustername}
    rm ignodes.yaml
    rm ignodesupdated.yaml
else
    echo your worker nodes MaxSize is $maxsize, which is fine. No need to update MaxSize
fi

#update the K8s cluster with the autoscaling IAM policy. Note that adding the policy more than once has no effect,
#so this can be rerun against clusters that already include this policy
echo updating the cluster with the autoscaling IAM policy
kops get cluster $clustername -o yaml > ${clustername}.yaml
config=${clustername}.yaml
policy=./cluster-scaling/templates/worker-iam-policy.yaml
cat "$policy" >> "$config"
kops replace -f ${config}
kops update cluster ${clustername} --yes
kops rolling-update cluster ${clustername}
rm ${config}

#update and apply the autoscaling yaml config
echo updating the autoscaling yaml config
sed "s/<NODE ASG>/$asgname/g" ./cluster-scaling/templates/2-10-autoscaler.yaml | \
sed "s/<REGION>/$region/g" > ./cluster-scaling/templates/temp-2-10-autoscaler.yaml
kubectl apply -f ./cluster-scaling/templates/temp-2-10-autoscaler.yaml

#check autoscaling service has started
while true; do
    if kubectl logs deployment/cluster-autoscaler --namespace=kube-system | grep -q 'successfully renewed lease'; then
        echo Autoscaling service has started
        break
    else
        echo Autoscaling service startup in progress. This may take a few seconds...
        sleep 5
        continue
    fi
done

#check that the scaling component is working correctly
./cluster-scaling/test.sh
