#!/bin/bash

## THIS RUNS AFTER THE elk/elk_deploy.sh

MONITOR_ELS_YML="elasticsearch-monitor.yaml"
MONITOR_KIB_YML="kibana-monitor.yaml"
MONITOR_LOG_YML="logstash-monitor.yaml"

MONITOR_ELS_NAME="elastin-monitor"
UPGRADE_MEM="mem-map-tweak.yaml"

ELK_NS="elk-ns"

# Upgrade mem map for ELS
kubectl get nodes --no-headers \
    -o custom-columns=":metadata.name" \
    | grep "^${MONITOR_ELS_NAME}-" \
    | xargs -I{} kubectl label node {} elasticsearch=enabled
kubectl apply -f "$UPGRADE_MEM"

# Built-in user for exporter
kubectl create secret generic elk-monitor-user-secret \
    --from-literal=remote_monitoring_collector="$PASSWORD" \
    -n "$ELK_NS"

## ELS CRD
kubectl apply -f "$MONITOR_ELS_YML"
PASSWORD=$(kubectl get secret "$MONITOR_ELS_NAME"-es-elastic-user -o go-template='{{.data.elastic | base64decode}}')
kubectl create secret generic elastin-monitor-creds --from-literal=ELS_MONITOR_PW="$PASSWORD" -n elk-ns

## Logstash CRD
kubectl apply -f "$MONITOR_LOG_YML"
## Kibana CRD
kubectl apply -f "$MONITOR_KIB_YML"
