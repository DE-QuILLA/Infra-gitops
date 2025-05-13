#!/bin/bash
set -e

# monitoring 네임 스페이스 - 프로메테우스 + 그라파나 배포, kafka exporter, Fluent Bit 배포
echo "🖥️ monitoring 네임스페이스 생성"
kubectl create ns monitoring || true
echo "✅ monitoring 네임스페이스 생성 완료!"

echo "🖥️ Monitoring Stack 배포 (Prometheus + Grafana)"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace \
  --set grafana.service.type=LoadBalancer \
  --set grafana.adminPassword='admin'    # pragma: allowlist secret
echo "✅ Monitoring Stack 배포 (Prometheus + Grafana) 완료!"

echo "🖥️ Monitoring Stack 배포 (Fluent Bit)"
ELS_PW=$(kubectl get secret elastintest-es-elastic-user -n elk-ns \
  -o go-template='{{.data.elastic | base64decode}}')

export ELS_PW
envsubst < fluent-bit-values.template.yaml > fluent-bit-values.yaml

helm upgrade --install fluent-bit fluent/fluent-bit \
  -n monitoring --create-namespace \
  -f fluent-bit-values.yaml
echo "✅ Monitoring Stack 배포 (Fluent Bit) 완료!"


echo "🖥️ Kafka 로그 용 exporter 설정"
kubectl apply -f ./kafka/kafka-export-svc.yaml
kubectl apply -f ./kafka/kafka-service-monitor.yaml
echo "✅ Kafka 로그 용 exporter 설정 완료!"

echo "🎉 monitoring 네임스페이스 내 모든 리소스 배포 완료!"
