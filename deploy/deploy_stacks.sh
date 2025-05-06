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
# 3. Monitoring tools
# =========================

echo -e "\n🌟Monitoring 도구 배포 중 ..."
kubectl create namespace monitoring

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set grafana.adminPassword='admin' \  # pragma: allowlist secret
  --set grafana.service.type=LoadBalancer


# =========================
# 3. Spark
# =========================

NAMESPACE="kafka"
STRIMZI_VERSION="0.46.0"
GRAFANA_NAMESPACE="monitoring"

echo "📁 Kafka 네임스페이스 생성"
kubectl create namespace $NAMESPACE || true

echo "📦 Strimzi Kafka Operator 설치"
curl -L $STRIMZI_DOWNLOAD_URL -o strimzi.tar.gz
tar -xzf strimzi.tar.gz
kubectl apply -f strimzi-cluster-operator-$STRIMZI_VERSION/install/cluster-operator -n $NAMESPACE

echo "⏳ Operator 준비 대기 중..."
kubectl rollout status deployment strimzi-cluster-operator -n $NAMESPACE

echo "🔧 KafkaNodePool 및 KafkaCluster 생성"
kubectl apply -f kafka-cluster.yaml -n $NAMESPACE
kubectl apply -f kafka-nodepool.yaml -n $NAMESPACE

echo "📈 Kafka Metrics용 ConfigMap 등록"
kubectl apply -f kafka-metrics-config.yaml -n $NAMESPACE

echo "📊 Grafana용 Kafka Dashboard ConfigMap 등록"
kubectl create namespace $GRAFANA_NAMESPACE || true
kubectl apply -f kafka-grafana-dashboard-configmap.yaml -n $GRAFANA_NAMESPACE

echo "🔍 ServiceMonitor 리소스 등록 (Prometheus 연동)"
kubectl apply -f kafka-servicemonitor.yaml -n $NAMESPACE

# =========================
echo -e "\n🎉 모든 서비스 배포 완료!"
echo "🔍 확인: kubectl get all --all-namespaces"
