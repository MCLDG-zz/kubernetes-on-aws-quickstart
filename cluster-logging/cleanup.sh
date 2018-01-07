#!/usr/bin/env bash

#function to read properties from quick-start.properties
function getprop {
    grep "${1}" quick-start.properties|cut -d'=' -f2
}

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
aws logs delete-log-group --log-group-name $(getprop 'k8s.clustername').logs

#delete the access keys
echo deleting access keys
output=`aws iam list-access-keys --user-name fluentd`
echo $output
numberaccesskeys=`echo ${output} | jq '.AccessKeyMetadata | length' | tr -d '"'`
echo number of access keys to be deleted is: $numberaccesskeys
for (( i=0; i<$numberaccesskeys; i++))
do
    accesskey=`echo ${output} | jq '.AccessKeyMetadata[$i].AccessKeyId' | tr -d '"'`
    echo deleting access key: $accesskey
    aws iam delete-access-key --access-key-id $accesskey --user-name fluentd
done
