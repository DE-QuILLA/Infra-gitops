#!/bin/bash
set -e

# [1] 변수 설정
echo "📌 1. 변수 설정 시작"
PROJECT_ID="de-quilla"
GSA_NAME="spark-gcs-access"
GSA_EMAIL="${GSA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
KSA_NAME="spark-sa"
NAMESPACE="spark"
SECRET_NAME="spark-gcp-key"  # pragma: allowlist secret
KEY_FILE="$(pwd)/spark_key.json"
echo "✔️ 1. 변수 설정 완료!"

# [2] gcloud 프로젝트 설정 확인
echo "📌 2. gcloud 프로젝트 설정"
gcloud config set project "$PROJECT_ID"
echo "✔️ 2. gcloud 프로젝트 설정 완료!"

# [3] GCP 서비스 계정 설정
echo "📌 3. GCP service account 설정"

# [3 - 1] 서비스 계정이 없으면 생성함
if ! gcloud iam service-accounts describe "$GSA_EMAIL" > /dev/null 2>&1; then
  echo "❓ GCP 서비스 계정이 없으므로 생성 : $GSA_NAME"
  gcloud iam service-accounts create "$GSA_NAME" \
    --project="$PROJECT_ID" \
    --display-name="Spark GCS Access"
else
  echo "✔️ GCP 서비스 계정이 이미 존재: $GSA_EMAIL"
fi

# [3 - 2] 서비스 계정 필수 권한 부여
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:$GSA_EMAIL" \
  --role="roles/storage.objectViewer"

echo "✔️ 3. GCP service account 준비 완료!"

# [4] 키 파일 생성
echo "📌 4. 키 파일 생성"
gcloud iam service-accounts keys create "$KEY_FILE" \
  --iam-account="$GSA_EMAIL" \
  --project="$PROJECT_ID"

echo "✔️ 4. spark - gcs 용 키 파일 준비 완료! : $KEY_FILE"

# [5] KSA(K8S 서비스 어카운트) 확인
echo "📌 5. KSA 확인 및 secret 생성"

# [5 - 1] KSA가 없다면 새롭게 생성
if ! kubectl get sa "$KSA_NAME" -n "$NAMESPACE" > /dev/null 2>&1; then
  echo "❓ '$KSA_NAME' 서비스 계정이 없으므로 생성: $KSA_NAME"
  kubectl create serviceaccount "$KSA_NAME" -n "$NAMESPACE"
else
  echo "✔️ 해당 KSA는 이미 존재 : $KSA_NAME"
fi

# [5 - 2] K8S Secret 생성
echo "📦 Kubernetes Secret 생성 중..."
kubectl delete secret "$SECRET_NAME" -n "$NAMESPACE" --ignore-not-found
kubectl create secret generic "$SECRET_NAME" \
  --from-file=key.json="$KEY_FILE" \
  -n "$NAMESPACE"

echo "✔️ 5. KSA 확인 및 secret 생성 완료!"

echo "✔️ Spark History Server의 GCS 접근을 위한 준비가 모두 완료!"
