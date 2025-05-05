#!/bin/bash
set -e
trap 'echo "⚠️ 배포 중 에러 발생! 스크립트 중단됨."; exit 1' ERR

# =========================
# CONFIG
# =========================
KEY_JSON_PATH="./key.json"

wait_for_pods() {
  local namespace="$1"
  echo "⏳ $namespace 네임스페이스의 모든 Pod가 Running 상태가 될 때까지 대기 중..."
  while [[ $(kubectl get pods -n "$namespace" --no-headers | grep -v 'Running\|Completed' | wc -l) -gt 0 ]]; do
    sleep 5
    kubectl get pods -n "$namespace"
  done
  echo "✅ $namespace 네임스페이스의 모든 Pod가 준비 완료!"
}

# =========================
# 1. Airflow
# =========================
echo -e "\n🚀 [1/3] Airflow 배포 시작..."

echo "📁 [Airflow] 네임스페이스 및 시크릿 구성 중..."
kubectl create ns airflow --dry-run=client -o yaml | kubectl apply -f -
kubectl delete secret cloudsql-instance-credentials -n airflow --ignore-not-found
kubectl create secret generic cloudsql-instance-credentials \
    --from-file=key.json="$KEY_JSON_PATH" \
    -n airflow

# Cloud SQL Proxy 배포
echo "\n💭Cloud SQL Proxy pod 배포 중 ..."
kubectl apply -f ./airflow/proxy-deployment.yaml -n airflow
wait_for_pods "airflow"

# Helm 설치 및 airflow 배포
helm repo add apache-airflow https://airflow.apache.org || true
helm repo update || true
helm upgrade --install airflow apache-airflow/airflow \
  -f "./airflow/airflow-values.yaml" \
  -n airflow

# =========================
# 2. Spark
# =========================
echo -e "\n🚀 [2/3] Spark 배포 시작..."
echo "📁 [Spark] 네임스페이스 및 GCS 접근 권한 구성 중..."
kubectl create ns spark --dry-run=client -o yaml | kubectl apply -f -
bash ./grant_gcs_access.sh

echo -e "\n🌟Spark Connect server 배포 중 ..."
helm repo add sdaberdaku https://sdaberdaku.github.io/charts || true
helm repo update

helm upgrade --install spark-connect sdaberdaku/spark-connect \
  -f "./spark/spark-connect-values.yaml" \
  -n spark

# Spark Connect 서버 배포 대기
wait_for_pods "spark"

echo -e "\n🌟Spark Operator 배포 중 ..."
helm repo add spark-operator https://googlecloudplatform.github.io/spark-on-k8s-operator
helm repo update

# Spark Operator 배포 대기
wait_for_pods "spark"

echo -e "\n🌟Spark history 서버 배포 중 ..."
kubectl apply -f ./spark/spark-history-server.yaml -n spark

# Spark history 서버 배포 대기
wait_for_pods "spark"

# =========================
echo -e "\n🎉 모든 서비스 배포 완료!"
echo "🔍 확인: kubectl get all --all-namespaces"
