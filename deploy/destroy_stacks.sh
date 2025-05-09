#!/bin/bash
set -e

# [0] 기본 설정
PROJECT_ID="de-quilla"
ZONE="asia-northeast3-a"
NAMESPACES=("airflow" "spark" "kafka-1" "elk" "monitoring")

for ns in "${NAMESPACES[@]}"; do
  echo -e "\n❗ [$ns] 네임스페이스 리소스 전체 삭제 시작"

  # [1] Helm Release 삭제
  echo "❗ Helm 릴리스 삭제 중..."
  helm ls -n "$ns" --no-headers | awk '{print $1}' | while read release; do
    echo "✅  Helm 릴리스 [$release] 삭제"
    helm uninstall "$release" -n "$ns" || true
  done

  # [2] 모든 K8s 리소스 삭제 (서비스, PVC, PV 등 포함)
  echo "❗ K8s 리소스 삭제 중..."
  kubectl delete all --all -n "$ns" || true
  kubectl delete pvc --all -n "$ns" || true
  kubectl delete pv --all -n "$ns" || true
  kubectl delete configmap --all -n "$ns" || true
  kubectl delete secret --all -n "$ns" || true
  kubectl delete serviceaccount --all -n "$ns" || true
  kubectl delete ingress --all -n "$ns" || true
  kubectl delete service --all -n "$ns" || true
  kubectl delete deployment --all -n "$ns" || true
  echo "✅ [$ns] 네임스페이스 내 K8S 리소스 전체 삭제 완료"


#   아래 내용의 추가를 보류 => 애초에 helm 혹은 kubectl용 yaml에서 reclaimPolicy: Delete를 설정하면 배포가 삭제될 때 같이 삭제되며, 이를 유지하는 것이 자연스럽다고 생각.

#   [3] PV 삭제
#   echo "❗ PV 중 [$ns] PVC에서 생성된 것 추적 중..."
#   pvc_list=$(kubectl get pvc -n "$ns" -o=jsonpath='{range .items[*]}{.spec.volumeName}{"\n"}{end}')
#   for pv in $pvc_list; do
#     echo "🗑️  PV [$pv] 삭제"
#     kubectl delete pv "$pv" || true
#   done

#   [4] GCP 디스크 삭제 (동적 프로비저닝된 디스크 추적)
#   echo "🧹 GCP 디스크 추적 및 삭제 중..."
#   for pv in $pvc_list; do
#     disk_name=$(kubectl get pv "$pv" -o jsonpath='{.spec.gcePersistentDisk.pdName}' || echo "")
#     if [ -n "$disk_name" ]; then
#       echo "⚠️  GCE 디스크 [$disk_name] 삭제"
#       gcloud compute disks delete "$disk_name" --zone "$ZONE" --project "$PROJECT_ID" --quiet || true
#     fi
#   done

  # [3] 네임스페이스 자체 삭제
  echo "🧹 네임스페이스 [$ns] 삭제"
  kubectl delete namespace "$ns" || true
done

echo -e "\n✅ 모든 네임스페이스 클린업 완료"
