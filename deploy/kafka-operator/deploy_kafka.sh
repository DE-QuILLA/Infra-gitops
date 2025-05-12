#!/bin/bash
set -e

# kafka-1 네임스페이스 - strimizi kafka operator + kafka cluster, kafka-ui 배포

echo "🖥️ kafka-1 네임스페이스 생성"
kubectl create namespace kafka-1 || true
echo "✅ Kafka-1 네임스페이스 생성 완료!"

echo "🖥️ strimzi-kafka-operator 배포"
helm repo add strimzi https://strimzi.io/charts/
helm repo update
helm upgrade --install strimzi-kafka-operator-1 \
    ./helm_custom/strimzi-kafka-operator/ \
    -n kafka-1 --create-namespace \
    -f kafka-operator-values.yaml
echo "✅ strimzi-kafka-operator 배포 완료!"

echo "🖥️ Kafka StorageClass, Kafka, NodePool 배포"
kubectl apply -f kafka-storage-class.yaml
kubectl apply -f kafka-cluster.yaml
kubectl apply -f kafka-node-pool.yaml
echo "✅ Kafka StorageClass, Kafka, NodePool 배포 완료!"

echo "🖥️ Kafka UI 배포"
helm repo add kafka-ui https://provectus.github.io/kafka-ui-charts
helm repo update
helm upgrade --install kafka-ui kafka-ui/kafka-ui \
    -n kafka-1 \
    -f kafka-ui.yaml
echo "✅ Kafka UI 배포 완료!"

echo "🖥️ Kafka Producer 배포"
PRODUCER_FOLDER="./kafka-producer"

for file in "$PRODUCER_FOLDER"/*.yaml "$PRODUCER_FOLDER"/*.yml; do
    if [ -f "$file" ]; then
        echo "$file 배포중!"
        kubectl apply -f "$file"
    fi
done
echo "✅ Kafka Producer 배포 완료!"

echo "🎉 kafka-1 네임스페이스 내 모든 리소스 배포 완료!"
