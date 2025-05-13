#!/bin/bash
set -e

# [2] spark 네임스페이스 - spark-connect, spark-history-server, spark-operator 배포
echo "🖥️ spark 네임스페이스 생성"
kubectl create namespace spark || true
echo "✅ spark 네임스페이스 생성 완료!"

echo "🖥️ Spark Connect Server 서버 배포"
helm repo add spark-connect https://sebastiandaberdaku.github.io/spark-connect-chart
helm repo update
helm upgrade --install spark-connect ./spark_connect -n spark -f spark-connect-values.yaml
echo "✅ Spark Connect Server 배포 완료!"

echo "🖥️ Spark Operator 배포"
helm repo add spark-operator https://kubeflow.github.io/spark-operator
helm repo update
helm upgrade --install spark-operator spark-operator/spark-operator --namespace spark -f spark-operator-values.yaml
echo "✅ Spark Operator 배포 완료!"

echo "🖥️ Spark History Server 배포 전 스파크 로그 GCS 관련 설정"
bash ./spark_gcs_access.sh
kubectl create serviceaccount spark-sa -n spark || true
kubectl create secret generic spark-gcp-key --from-file=key.json=./spark_key.json -n spark || true
echo '{}' > dummy.json
gsutil cp dummy.json gs://deq-spark-log-bucket/spark-events/.dummy || echo "gsutil 업로드 실패 (무시 중)"
echo "✅ Spark History Server GCS touch 완료!"

echo "🖥️ Spark History Server 배포"
kubectl apply -f spark-history-server.yaml
echo "✅ Spark History Server 배포 완료!"

echo "🎉 spark 네임 스페이스 내 모든 리소스 배포 완료!"
