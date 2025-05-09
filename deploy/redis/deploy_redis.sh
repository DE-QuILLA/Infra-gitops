#!/bin/bash
set -e

# redis 네임스페이스 - ingestion 사용 redis 배포

echo "🖥️ redis 네임스페이스 생성"
kubectl create namespace redis || true
echo "✅ redis 네임스페이스 생성 완료!"

echo "🖥️ redis 배포"
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install redis bitnami/redis -n redis \
  --set auth.enabled=false \
  --set architecture=standalone \
  --set master.persistence.enabled=false
echo "✅ redis 배포 완료!"

echo "🎉 redis 네임스페이스 내 모든 리소스 배포 완료!"
