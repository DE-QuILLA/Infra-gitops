#!/bin/bash
set -e
trap 'echo "⚠️ 배포 중 에러 발생! 스크립트 중단됨."; exit 1' ERR

# =========================
# CONFIG
# =========================
KEY_JSON_PATH="./key.json"
DB_CONN_STR="postgresql+psycopg2://airflow:postgres@127.0.0.1:5432/airflowdb"  # pragma: allowlist secret

wait_for_pods() {
  local namespace="$1"
  echo "⏳ $namespace 네임스페이스의 모든 Pod가 Running 상태가 될 때까지 대기 중..."
  while [[ $(kubectl get pods -n "$namespace" --no-headers | grep -v 'Running\|Completed' | wc -l) -gt 0 ]]; do
    sleep 5
    kubectl get pods -n "$namespace"
  done
  echo "✅ $namespace 네임스페이스의 모든 Pod가 준비 완료!"
}

create_namespace_and_secret() {
  local namespace="$1"
  echo "📁 [$namespace] 네임스페이스 및 시크릿 구성 중..."
  kubectl create ns "$namespace" --dry-run=client -o yaml | kubectl apply -f -
  kubectl delete secret cloudsql-instance-credentials -n "$namespace" --ignore-not-found
  kubectl create secret generic cloudsql-instance-credentials \
    --from-file=key.json="$KEY_JSON_PATH" \
    -n "$namespace"
}

# =========================
# 1. Airflow
# =========================
echo -e "\n🚀 [1/3] Airflow 배포 시작..."
create_namespace_and_secret "airflow"

# Cloud SQL Proxy 배포
kubectl apply -f ./airflow/proxy-deployment.yaml -n airflow
wait_for_pods "airflow"

# Helm 설치
helm repo add apache-airflow https://airflow.apache.org || true
helm repo update
helm upgrade --install airflow apache-airflow/airflow \
  -f "./airflow/values.yaml" \
  -n airflow

# =========================
# 2. Spark Connect
# =========================
echo -e "\n🚀 [2/3] Spark Connect 배포 시작..."
create_namespace_and_secret "spark"

helm repo add sdaberdaku https://sdaberdaku.github.io/charts || true
helm repo update

helm upgrade --install spark-connect sdaberdaku/spark-connect \
  -f "./spark/spark-connect-values.yaml"
  -n spark

# Spark Connect 서버 배포
wait_for_pods "spark"

# =========================
# 3. ELK Stack
# =========================
echo -e "\n🚀 [3/3] ELK Stack 배포 시작..."
kubectl create ns elk --dry-run=client -o yaml | kubectl apply -f -

helm repo add elastic https://helm.elastic.co || true
helm repo update

# Elasticsearch
helm upgrade --install elasticsearch elastic/elasticsearch \
  -f "./elk/elastic-values.yaml" \
  -n elk

# Kibana
helm upgrade --install kibana elastic/kibana \
  -f "./elk/kibana-values.yaml" \
  -n elk

wait_for_pods "elk"

# =========================
echo -e "\n🎉 모든 서비스 배포 완료!"
echo "🔍 확인: kubectl get all --all-namespaces"
