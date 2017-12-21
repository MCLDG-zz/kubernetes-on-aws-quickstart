#!/usr/bin/env bash

##delete Fluentd
#kubectl delete -f ./cluster-logging/templates/fluentd-ds.yaml
#kubectl delete -f ./cluster-logging/templates/fluentd-svc.yaml
#kubectl delete -f ./cluster-logging/templates/fluentd-configmap.yaml
#
##delete the service accounts and roles:
#kubectl delete -f ./cluster-logging/templates/fluentd-role-binding.yaml
#kubectl delete -f ./cluster-logging/templates/fluentd-role.yaml
#kubectl delete -f ./cluster-logging/templates/fluentd-service-account.yaml
#
##delete the namespace
#kubectl delete ns logging
#
##delete the elasticsearch domain
#aws es delete-elasticsearch-domain --domain-name kubernetes-logs
#
##delete the log group
#aws logs delete-log-group --log-group-name $(getprop 'k8s.clustername').logs

#delete the access keys
output=`aws iam list-access-keys --user-name fluentd`
echo $output
accesskey=`echo ${output} | jq '.AccessKeyMetadata[0].AccessKeyId' | tr -d '"'`
echo $accesskey
aws iam delete-access-key --access-key-id $accesskey --user-name fluentd
accesskey=`echo ${output} | jq '.AccessKeyMetadata[1].AccessKeyId' | tr -d '"'`
echo $accesskey
aws iam delete-access-key --access-key-id $accesskey --user-name fluentd

