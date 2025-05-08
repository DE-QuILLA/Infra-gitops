#!/bin/bash
set -e

# [1] airflow 네임스페이스 - CloudSQL Proxy + Airflow 배포
echo "🖥️ Airflow 네임스페이스 및 Secret 생성"
kubectl create namespace airflow || true
kubectl create secret generic gcp-key --from-file=key.json=./key.json -n airflow || true

echo "🖥️ Airflow Proxy 및 Helm으로 Airflow 배포"
kubectl apply -f ./airflow/proxy-deployment.yaml
helm repo add apache-airflow https://airflow.apache.org
helm repo update
helm upgrade airflow apache-airflow/airflow --install -f airflow-values.yaml -n airflow
echo "✅ Airflow 배포 완료!"

# [2] spark 네임스페이스 - spark-connect, spark-history-server, spark-operator 배포
echo "🖥️ Spark Connect 서버 배포"
kubectl create namespace spark || true
helm repo add spark-connect https://sebastiandaberdaku.github.io/spark-connect-chart
helm repo update
helm upgrade --install spark-connect ./spark/spark_connect -n spark -f ./spark/spark-connect-values.yaml
echo "✅ Spark-connect 배포 완료!"

echo "🖥️ Spark Operator 배포"
helm repo add spark-operator https://kubeflow.github.io/spark-operator
helm repo update
helm upgrade --install spark-operator spark-operator/spark-operator --namespace spark -f ./spark/spark-operator-values.yaml
echo "✅ Spark Operator 배포 완료!"

echo "🖥️ Spark History Server 설정"
bash ./spark_gcs_access.sh
kubectl create serviceaccount spark-sa -n spark || true
kubectl create secret generic spark-gcp-key --from-file=key.json=./spark_key.json -n spark || true
echo '{}' > dummy.json
gsutil cp dummy.json gs://deq-spark-log-bucket/spark-events/.dummy || echo "gsutil 업로드 실패 (무시 중)"
kubectl apply -f spark-history-server.yaml
echo "✅ Spark History Server 배포 완료!"

# [3] kafka-1 네임스페이스 - strimizi kafka operator + kafka cluster, kafka-ui 배포
echo "🖥️ Kafka 네임스페이스 및 Operator 설치"
kubectl create namespace kafka-1 || true
helm repo add strimzi https://strimzi.io/charts/
helm repo update
helm upgrade --install strimzi-kafka-operator-1 \
    ./kafka-operator/helm_custom/strimzi-kafka-operator/ \
    -n kafka-1 --create-namespace \
    -f ./kafka-operator/kafka-operator-values.yaml

echo "🖥️ Kafka StorageClass, Cluster, NodePool 설정"
kubectl apply -f ./kafka-operator/kafka-storage-class.yaml
kubectl apply -f ./kafka-operator/kafka-cluster.yaml
kubectl apply -f ./kafka-operator/kafka-node-pool.yaml
echo "✅ Kafka Cluster 배포 완료!"

echo "🖥️ Kafka UI 설치"
helm repo add kafka-ui https://provectus.github.io/kafka-ui-charts
helm repo update
helm upgrade --install kafka-ui kafka-ui/kafka-ui   -n kafka-1   -f kafka-ui.yaml
echo "✅ Kafka UI 배포 완료!"

# [4] monitoring 네임 스페이스 - 프로메테우스 + 그라파나 배포, kafka exporter 배포
echo "🖥️ Monitoring Stack 설치 (Prometheus + Grafana)"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace \
  --set grafana.service.type=LoadBalancer \
  --set grafana.adminPassword='coffeeisnak'  # pragma: allowlist secret
kubectl apply -f kafka-export-svc.yaml
kubectl apply -f kafka-service-monitor.yaml
echo "✅ Monitoring 스택들 배포 완료!"

echo "🎉 모든 컴포넌트 배포 완료!"
