#!/usr/bin/env bash

#Monitoring - deploying Prometheus
echo deploying Prometheus for Monitoring

#deploy the Prometheus operator
echo deploying Prometheus Operator
kubectl apply -f ./cluster-monitoring/templates/prometheus/prometheus-bundle.yaml

#check that the operator has started successfully
kubectl rollout status deployment/prometheus-operator -n monitoring

#deploy Prometheus custom resource
echo deploying Prometheus custom resource
kubectl apply -f ./cluster-monitoring/templates/prometheus/prometheus.yaml

#wait for Prometheus to start
kubectl get po -l prometheus=prometheus -n monitoring

#though Prometheus has a rudimentary dashboard, we typically use Grafana as the dashboard for visualizing Prometheus metrics
echo deploying Grafana dashboard
kubectl apply -f ./cluster-monitoring/templates/prometheus/grafana-bundle.yaml

#wait for Grafana to start
kubectl rollout status deployment/grafana -n monitoring

#check that the logging component is working correctly
./cluster-monitoring/test.sh
