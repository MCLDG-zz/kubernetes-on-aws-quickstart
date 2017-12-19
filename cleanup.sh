#!/usr/bin/env bash

#function to read properties from quick-start.properties
function getprop {
    grep "${1}" quick-start.properties|cut -d'=' -f2
}

#delete Fluentd
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
aws es delete-elasticsearch-domain --domain-name kubernetes-logs

#delete the log group
aws logs delete-log-group --log-group-name $(getprop 'k8s.clustername').logs
