#!/bin/bash

## DEPLOYS BOTH ECK AND ELK CRDs for ETL

ELS_YAMUL="fantasticsearch.yaml"
KIB_YAMUL="kinkybanana.yaml"
LOG_YAMUL="mustasche.yaml"

UPGRADE_MEM="mem-map-tweak.yaml"
ELS_NAME="elastin"

ELK_NS="elk-ns"

helm repo add elastic https://helm.elastic.co

# Deploy ECK and wait for it to wreak havoc, terminate when hell freezes over
helm install elastic-operator elastic/eck-operator -n "$ELK_NS" --create-namespace --wait --timeout 300s

## Upgrade mem map for ELS
# ELS filter
kubectl get nodes --no-headers \
    -o custom-columns=":metadata.name" \
    | grep "^${ELS_NAME}-" \
    | xargs -I{} kubectl label node {} elasticsearch=enabled
kubectl apply -f "$UPGRADE_MEM"

## ELS CRD
kubectl apply -f "$ELS_YAMUL"

# DEBUG: Get http service
# kubectl get service "$ELS_NAME"-es-http -n "$ELK_NS"

# Get cred. user: elastic
PASSWORD=$(kubectl get secret "$ELS_NAME"-es-elastic-user -o go-template='{{.data.elastic | base64decode}}')

# Create a connection secret
kubectl create secret generic elastin-creds --from-literal=ELS_PW="$PASSWORD" -n elk-ns

## Optional
# ELS info print: Dunno if a pseudo tty is permitted in git action tho 🤔
kubectl port-forward service/"$ELS_NAME"-es-http 9200 -n > kubeproxy.log 2>&1 &
curl -u "elastic:$PASSWORD" -k "https://localhost:9200"
# Terminate proxy
pkill -f "kubectl port-forward"

## Logstash CRD
kubectl apply -f "$LOG_YAMUL"
## Kibana CRD
kubectl apply -f "$KIB_YAMUL"
