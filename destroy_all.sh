#!/bin/bash
set -e

# 깃헙 프로젝트 최상단 경로
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ID="de-quilla"

# [1] GKE 내 데이터 스택 삭제
echo -e "\n❗ [deploy] 사용 데이터 스택 삭제 시작\n"
chmod +x "$ROOT_DIR/deploy/destroy_stacks.sh"
bash "$ROOT_DIR/deploy/destroy_stacks.sh"
echo -e "\n✅ [deploy] 사용 스택 삭제 완료!\n"

sleep 3

# [2] 테라폼 적용 GCP 클라우드 인프라 삭제
echo -e "\n❗ [terraform] 테라폼 적용 GCP 인프라 삭제 시작\n"
cd "$ROOT_DIR/terraform" && terraform destroy -auto-approve
echo -e "\n✅ [terraform] 테라폼 적용 GCP 인프라 삭제 완료!\n"

echo -e "\n\n✅ 전체 인프라 삭제가 완료되었습니다!\n\n"

echo -e "\n⚠️ 잔여 자원(DISK) 출력!\n"
gcloud compute disks list --project="$PROJECT_ID" --filter="-users:*"
echo -e "\n⚠️ GCP 콘솔에서 잔여 리소스 수동 확인 권장!\n"
