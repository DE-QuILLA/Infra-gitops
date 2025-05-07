#!/bin/bash

ELS_YAMUL="bhandhasticsearch.yaml"
ELS_NAME="elastintest"
KIB_YAMUL="kinkybanana.yaml"
LOG_YAMUL="mustasche.yaml"
ELK_NS="elk-ns"

helm install elastic-operator elastic/eck-operator -n "$ELK_NS" --create-namespace

# wait for it to finish deployment

# els crd
kubectl apply -f "$ELS_YAMUL"

# get green health (kibana might be dep on it)

# get http service
kubectl get service "$ELS_NAME"-es-http -n "$ELK_NS"

# get cred. user: elastic
PASSWORD=$(kubectl get secret "$ELS_NAME"-es-elastic-user -o go-template='{{.data.elastic | base64decode}}')

# ELS info print (temp proxy ... if only it were that easy😥)
kubectl port-forward service/"$ELS_NAME"-es-http 9200 -n > kubeproxy.log 2>&1 &
curl -u "elastic:$(cat ./deploy/elk/els_pw)" -k "https://localhost:9200"
# Terminate proxy
pkill -f "kubectl port-forward"

# logstash crd

# kibana crd
