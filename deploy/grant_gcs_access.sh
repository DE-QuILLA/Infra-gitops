#!/bin/bash
set -e

PROJECT_ID=$(gcloud config get-value project)
ZONE=$(gcloud config get-value compute/zone)
CLUSTER_NAME="data-gke"

echo "🔍 GKE 노드에 할당된 서비스 계정 확인 중..."
GSA=$(gcloud container clusters describe $CLUSTER_NAME \
  --zone $ZONE \
  --format="value(nodeConfig.serviceAccount)")

if [[ -z "$GSA" ]]; then
  echo "⚠️  기본 GCE 서비스 계정 사용 중. 자동 추출 중..."
  PROJECT_NUM=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
  GSA="$PROJECT_NUM-compute@developer.gserviceaccount.com"
fi

echo "✅ 사용할 GCP 서비스 계정: $GSA"

echo "🔐 roles/storage.objectAdmin 권한을 부여합니다..."
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$GSA" \
  --role="roles/storage.objectAdmin" \
  --quiet

echo "🎉 권한 설정 완료. $GSA 계정은 이제 GCS에 쓰기 가능!"
