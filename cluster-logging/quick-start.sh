#!/usr/bin/env bash

#Consolidated logging - deploy an EFK stack
echo deploying an EFK stack for consolidated logging

region=$(getprop 'aws.region')
account=`aws sts get-caller-identity --output text --query 'Account'`

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