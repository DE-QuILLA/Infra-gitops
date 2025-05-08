#!/bin/bash

set -e

# === 환경 설정 ===
PROJECT_ID="de-quilla"
GSA_NAME="spark-gcs-access"
GSA_EMAIL="${GSA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
KSA_NAME="spark-sa"
NAMESPACE="spark"
SECRET_NAME="spark-gcp-key"  # pragma: allowlist secret
KEY_FILE="$(pwd)/spark_key.json"

# 🔧 [0] gcloud 프로젝트 설정 확인
gcloud config set project "$PROJECT_ID"

# 🔧 [1] GCP 서비스 계정이 없으면 생성
if ! gcloud iam service-accounts describe "$GSA_EMAIL" > /dev/null 2>&1; then
  echo "📌 GCP 서비스 계정이 없으므로 생성합니다: $GSA_NAME"
  gcloud iam service-accounts create "$GSA_NAME" \
    --project="$PROJECT_ID" \
    --display-name="Spark GCS Access"
else
  echo "✔️ GCP 서비스 계정이 이미 존재합니다: $GSA_EMAIL"
fi

# 🔧 [2] 필수 권한 부여
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:$GSA_EMAIL" \
  --role="roles/storage.objectViewer"

# 🔑 [3] 키 파일 생성
echo "🔐 키 파일 생성 중..."
gcloud iam service-accounts keys create "$KEY_FILE" \
  --iam-account="$GSA_EMAIL" \
  --project="$PROJECT_ID"

echo "✅ 키 파일 생성 완료: $KEY_FILE"

# 🧾 [4] KSA 확인
if ! kubectl get sa "$KSA_NAME" -n "$NAMESPACE" > /dev/null 2>&1; then
  echo "📌 '$KSA_NAME' 서비스 계정이 없으므로 생성합니다."
  kubectl create serviceaccount "$KSA_NAME" -n "$NAMESPACE"
else
  echo "✔️ '$KSA_NAME' KSA는 이미 존재합니다."
fi

# 📦 [5] Secret 생성
echo "📦 Kubernetes Secret 생성 중..."
kubectl delete secret "$SECRET_NAME" -n "$NAMESPACE" --ignore-not-found
kubectl create secret generic "$SECRET_NAME" \
  --from-file=key.json="$KEY_FILE" \
  -n "$NAMESPACE"

echo "🎉 완료! Secret '$SECRET_NAME' 생성 완료"
echo "📄 JSON 키 파일: $KEY_FILE (절대 Git에 커밋 ❌)"
