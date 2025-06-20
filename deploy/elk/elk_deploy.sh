#!/bin/bash

set -euo pipefail

## DEPLOYS BOTH ECK AND ELK CRDs for ETL

ELS_YAMUL="fantasticsearch.yaml"
KIB_YAMUL="kinkybanana.yaml"
LOG_YAMUL="mustasche.yaml"

UPGRADE_MEM="mem-map-tweak.yaml"

ELS_NAME="elastin"
KIB_NAME="elastin-kibana"

ELK_NS="elk-ns"

## ECK OPERATOR
# Deploy ECK and wait for it to wreak havoc, terminate when hell freezes over
echo "🎁 Deploying ECK to cluster..."
helm repo add elastic https://helm.elastic.co
helm install elastic-operator elastic/eck-operator -n "$ELK_NS" --create-namespace --wait --timeout 300s

## ELASTICSEARCH
# Mem map daemonset for els
echo "🔼 Upgrading mem map for Elasticsearch"
kubectl get nodes --no-headers \
    -o custom-columns=":metadata.name" \
    | grep "^${ELS_NAME}-" \
    | xargs -I{} kubectl label node {} elasticsearch=enabled
kubectl apply -f "$UPGRADE_MEM"

# Deploy Elasticsearch and wait
echo "🎇 Applying Elasticsearch CRD..."
kubectl apply -f "$ELS_YAMUL"
echo "⌛ Waiting for pods to warm up..."
kubectl wait --namespace "$ELK_NS" \
    --for=condition=ready pod \
    --selector="elasticsearch.k8s.elastic.co/cluster-name=${ELS_NAME}" \
    --timeout=600s

# DEBUG: Get http service
# kubectl get service "$ELS_NAME"-es-http -n "$ELK_NS"

# Create cred and conn secret. default user: elastic. pw variable: ELS_PW
echo "🔑 Fetching credentials..."
PASSWORD=$(
    kubectl get secret "$ELS_NAME"-es-elastic-user \
    -o go-template='{{.data.elastic | base64decode}}' \
    -n "$ELK_NS"
)
kubectl create secret generic elastin-creds --from-literal=ELS_PW="$PASSWORD" -n "$ELK_NS"

# Proxy for ELS replica setting injection
echo "🥅 Opening proxy for config injection..."
kubectl port-forward "svc/${ELS_NAME}-es-http" "9200:9200" -n "$ELK_NS" >/dev/null &
PF_PID_ELS=$!

# the jq part can be removed if the prompt is too overwhelming
echo "🎇 Applying Elasticsearch cluster config..."
curl -s -u "elastic:${PASSWORD}" -k -X PUT "https://localhost:9200/_cluster/settings" \
    -H 'Content-Type: application/json' \
    -d '{"persistent": {"index.number_of_replicas":0}}' \
    | jq .

# DEBUG: Endpoint tests
# curl -u "elastic:$PASSWORD" -k "https://localhost:9200"
# Terminate proxy
# pkill -f "kubectl port-forward"

## LOGSTASH: *aborted*
# kubectl apply -f "$LOG_YAMUL"

## KIBANA
echo "🎇 Applying Kibana CRD..."
kubectl apply -f "$KIB_YAMUL"

# Dashboard injection. this section is undergoing tests
echo "⌛ Waiting for pods to warm up..."
kubectl wait -n "$ELK_NS" \
    pod -l kibana.k8s.elastic.co/name="$KIB_NAME" \
    --for=condition=Ready --timeout=600s
# kubectl -n elk-ns port-forward svc/"$KIB_NAME"-kb-http 5601 &
# PF_PID_KIB=$!
# PASS=$(kubectl -n elk-ns get secret "$KIB_NAME"-kb-kibana-user -o go-template='{{.data.kibana | base64decode}}')

# ANL_DASHBOARD="analysis_dashboard.ndjson"
# MON_DASHBOARD="monitoring_dashboard.ndjson"
# curl -u "kibana:$PASSWORD" -k \
#     -H "kbn-xsrf: true" \
#     -F "file=@${ANL_DASHBOARD}" \
#     https://localhost:5601/api/saved_objects/_import
# curl -u "kibana:$PASSWORD" -k \
#     -H "kbn-xsrf: true" \
#     -F "file=@${MON_DASHBOARD}" \
#     https://localhost:5601/api/saved_objects/_import

echo "✅ Done with ELK!"
trap 'kill $PF_PID_ELS $PF_PID_KIB' EXIT # end bg process on exit sig
