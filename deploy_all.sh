#!/bin/bash
set -e

# 깃헙 프로젝트 최상단 경로
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# [1] 테라폼 적용, GCP 클라우드 인프라 프로비저닝
echo -e "\n❗ [terraform] 테라폼 적용, GCP 인프라 프로비저닝 시작\n"
chmod +x "$ROOT_DIR/terraform/deploy_infra.sh"
bash "$ROOT_DIR/terraform/deploy_infra.sh"
echo -e "\n✅ [terraform] 테라폼 적용 완료, GCP 인프라 프로비저닝 완료!\n"

sleep 3

# [2] GKE 내 데이터 스택 배포
echo -e "\n❗ [deploy] 사용 데이터 스택 배포 시작\n"
chmod +X "$ROOT_DIR/deploy/deploy_stacks.sh"
bash "$ROOT_DIR/deploy/deploy_stacks.sh"
echo -e "\n✅ [deploy] 사용 스택 배포 완료!\n"

echo -e "\n\n✅ 전체 인프라 배포가 완료되었습니다!\n\n"
