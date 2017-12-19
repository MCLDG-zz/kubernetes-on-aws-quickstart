#!/usr/bin/env bash

#function to read properties from quick-start.properties
function getprop {
    grep "${1}" quick-start.properties|cut -d'=' -f2
}

region=$(getprop 'aws.region')
account=`aws sts get-caller-identity --output text --query 'Account'`

echo your region is ${region}
echo your account is ${account}

##install homebrew
#/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
#
##install Kops - used to create a K8s cluster
#brew update && brew install kops
#brew upgrade kops
#
##create ssh key, used by Kops. This will not overwrite an existing ssh key. If no ssh key exists, it will generate
##a new key with no passphrase
#cat /dev/zero | ssh-keygen -q -N ""
#
##enable versioning on your bucket
#aws s3api put-bucket-versioning \
#      --bucket $(getprop 's3.bucketname') \
#      --versioning-configuration Status=Enabled
#
#export KOPS_STATE_STORE=s3://$(getprop 's3.bucketname')
#
##create the K8s cluster
#echo creating the Kubernetes cluster
#if [$(getprop 'k8s.workernode.count') -lt 3]; then
#    masternodecount=1
#else
#    masternodecount=3
#fi
#
#kops create cluster $(getprop 'k8s.clustername').cluster.k8s.local \
#    --cloud aws \
#    --master-count $masternodecount \
#    --master-size $(getprop 'k8s.master.instancetype') \
#    --master-zones $(getprop 'az') \
#    --node-count $(getprop 'k8s.workernode.count') \
#    --node-size $(getprop 'k8s.node.instancetype') \
#    --zones $(getprop 'az') \
#
#kops update cluster mcdgk8s.cluster.k8s.local --yes
#
##validate the cluster has installed correctly
#echo it usually takes around 5 minutes to provision a K8s cluster. This script will keep checking until the cluster is created
#echo if you wish, you can check your EC2 console to see the creation status of the master and worker nodes
#while true; do
#    if kops validate cluster | grep -q 'Your cluster .* is ready'; then
#        echo K8s cluster installed correctly
#        break
#    else
#        echo K8s cluster installing...
#        sleep 10
#        continue
#    fi
#done
#
##install kubectl
#curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/darwin/amd64/kubectl
#chmod +x ./kubectl
#sudo mv ./kubectl /usr/local/bin/kubectl
#
##check that kubectl was installed and configured correctly
#kubectl cluster-info

##Consolidated logging - deploy an EFK stack
#echo deploying an EFK stack for consolidated logging
#
##deploy ElasticSearch. This takes a while, usually around 10 minutes
#echo creating an ElasticSearch cluster
#
#aws es create-elasticsearch-domain \
#  --domain-name kubernetes-logs \
#  --elasticsearch-version 5.5 \
#  --elasticsearch-cluster-config \
#  InstanceType=m4.large.elasticsearch,InstanceCount=2 \
#  --ebs-options EBSEnabled=true,VolumeType=standard,VolumeSize=100 \
#  --access-policies '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"AWS":["*"]},"Action":["es:*"],"Resource":"*"}]}' \
#  --region $region
#
##wait until ElasticSearch cluster has been successfully created
#while true; do
#    if aws es describe-elasticsearch-domain --domain-name kubernetes-logs --query 'DomainStatus.Processing' --region $region | grep -q 'false'; then
#        echo ElasticSearch cluster created
#        break
#    else
#        echo ElasticSearch cluster creating. This may take around 10 minutes...
#        sleep 60
#        continue
#    fi
#done

##create a CloudWatch log group. Fluentd will be configured to push logs to this log group
#echo create a CloudWatch log group
#aws logs create-log-group --log-group-name $(getprop 'k8s.clustername').logs --region $region
#
##now setup Fluentd
##first, create the Fluentd user
#echo deploying fluentd
#aws iam create-user --user-name fluentd
#
##the policy requires an account ID and a log group name
#sed "s/<account>/$account/g" ./cluster-logging/templates/fluentd-iam-policy.json | \
#sed "s/<log-group>/$(getprop 'k8s.clustername').logs/g"  > ./cluster-logging/templates/temp-fluentd-iam-policy.json
#aws iam put-user-policy --user-name fluentd --policy-name FluentdPolicy --policy-document file://cluster-logging/templates/temp-fluentd-iam-policy.json
#rm ./cluster-logging/templates/temp-fluentd-iam-policy.json

output=`aws iam create-access-key --user-name fluentd`
echo $output

#we need to replace the `AWS_ACCESS_KEY`, `AWS_SECRET_KEY` and `AWS_REGION` in the `templates/fluentd-ds.yaml` file.
accesskey=`echo ${output} | jq '.AccessKey.AccessKeyId'`
secretaccesskey=`echo ${output} | jq '.AccessKey.SecretAccessKey'`

echo $accesskey

#cp ./cluster-logging/templates/fluentd-ds.yaml ./cluster-logging/templates/fluentd-ds.yaml.bu
sed "s/<AWS_ACCESS_KEY>/$accesskey/g" ./cluster-logging/templates/fluentd-ds.yaml | \
sed "s|<AWS_SECRET_KEY>|${secretaccesskey}|g" | \
sed "s/<AWS_REGION>/$region/g" > ./cluster-logging/templates/temp-fluentd-ds.yaml

sed "s/kubernetes-logs/$(getprop 'k8s.clustername').logs/g" ./cluster-logging/templates/fluentd-configmap.yaml \
> ./cluster-logging/templates/temp-fluentd-configmap.yaml

#create create the logging namespace
kubectl create ns logging

#create all of the necessary service accounts and roles:
kubectl create -f ./cluster-logging/templates/fluentd-service-account.yaml
kubectl create -f ./cluster-logging/templates/fluentd-role.yaml
kubectl create -f ./cluster-logging/templates/fluentd-role-binding.yaml

#then deploy Fluentd:
kubectl create -f ./cluster-logging/templates/temp-fluentd-configmap.yaml
kubectl create -f ./cluster-logging/templates/fluentd-svc.yaml
kubectl create -f ./cluster-logging/templates/temp-fluentd-ds.yaml


#check for all of the pods to change to running status
kubectl get pods --namespace=logging

#delete the temp fluentd config, which we created above
#rm ./cluster-logging/templates/temp-fluentd-ds.yaml
#rm ./cluster-logging/templates/temp-fluentd-configmap.yaml

## Delete the Cluster
#kops delete cluster --name $(getprop 'k8s.clustername').cluster.k8s.local