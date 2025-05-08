#!bin/bash
set -e

echo "\n전체 인프라 배포를 시작합니다.\n"

echo "\n[terraform] 테라폼 적용, GCP 인프라 배포 시작\n"
chmod +x ./terraform/deploy_infra.sh && ./terraform/deploy_infra.sh
echo "\n[terraform] 테라폼 적용 완료, GCP 인프라 배포 완료\n"

sleep 5

echo "\n[deploy] 사용 스택 배포 시작\n"
chmod +x ./deploy/deploy_stacks.sh && ./deploy/deploy_stacks.sh
echo "\n[deploy] 사용 스택 배포 완료\n"
