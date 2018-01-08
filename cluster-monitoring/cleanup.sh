#!/usr/bin/env bash

#Monitoring - deleting Prometheus
echo deleting Prometheus Monitoring

#delete Grafana
echo deleting the Grafana dashboard
kubectl delete -f ./cluster-monitoring/templates/prometheus/grafana-bundle.yaml

#delete Prometheus custom resource
echo deleting the Prometheus custom resource
kubectl delete -f ./cluster-monitoring/templates/prometheus/prometheus.yaml

#delete Prometheus operator
echo deleting the Prometheus Operator
kubectl delete -f ./cluster-monitoring/templates/prometheus/prometheus-bundle.yaml

#wait for the monitoring namespace to terminate
while true; do
    if kubectl get ns | grep -q 'monitoring'; then
        echo Monitoring namespace still present, waiting .....
        sleep 5
        continue
    else
        echo Monitoring namespace terminated
        break
    fi
done


