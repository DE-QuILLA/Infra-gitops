#!/bin/bash
set -e

echo "inventory_kafka.ini 파일 동적 생성 중..."
bash ./generate_kafka_inventory.sh
sleep 2

echo "[Ansbible] Kafka 배포 시작"
ansible-playbook kafka.yml # -vvv verbose 비슷한 옵션이나 쓰면 너무 빠르게 흘러서 아무것도 안보임.

ansible kafka -m shell -a "systemctl is-active kafka"
