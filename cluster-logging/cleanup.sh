#!/usr/bin/env bash

#function to read properties from quick-start.properties
function getprop {
    grep "${1}" quick-start.properties|cut -d'=' -f2
}

region=$(getprop 'aws.region')
account=`aws sts get-caller-identity --output text --query 'Account'`
loggroup=$(getprop 'k8s.clustername')-logs

#delete the busybox test pod
kubectl delete -f ./cluster-logging/test/write-logs.yaml

#Consolidated logging - deploy an EFK stack
echo cleaning up EFK stack for consolidated logging

#delete Fluentd
echo deleting Fluentd
kubectl delete -f ./cluster-logging/templates/fluentd-ds.yaml
kubectl delete -f ./cluster-logging/templates/fluentd-svc.yaml
kubectl delete -f ./cluster-logging/templates/fluentd-configmap.yaml

#delete the service accounts and roles:
kubectl delete -f ./cluster-logging/templates/fluentd-role-binding.yaml
kubectl delete -f ./cluster-logging/templates/fluentd-role.yaml
kubectl delete -f ./cluster-logging/templates/fluentd-service-account.yaml

#delete the namespace
kubectl delete ns logging

#delete the elasticsearch domain
echo deleting ElasticSearch
aws es delete-elasticsearch-domain --domain-name kubernetes-logs

#delete the log group
echo deleting the log group $loggroup
aws logs delete-log-group --log-group-name $loggroup --region $region

#delete the access keys
echo deleting access keys
output=`aws iam list-access-keys --user-name fluentd`
for accesskey in $(echo "${output}" | jq -r '.AccessKeyMetadata[] | "\(.AccessKeyId)"');
do
    echo deleting access key ${accesskey}
    aws iam delete-access-key --access-key-id $accesskey --user-name fluentd
done

#delete the Fluentd user
echo deleting fluentd user
aws iam delete-user-policy --user-name fluentd --policy-name FluentdPolicy
aws iam delete-user --user-name fluentd
