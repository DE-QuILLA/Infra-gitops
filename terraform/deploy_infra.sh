#!/bin/bash
set -e  # 에러 발생 시 스크립트 종료

echo "✅ Step 0: Terraform init"
cd terraform && terraform init

echo "✅ Step 1: VPC"
terraform apply -target=module.vpc -auto-approve

echo "✅ Step 2: CloudSQL"
terraform apply -target=module.cloudsql -auto-approve

echo "✅ Step 3: GKE"
terraform apply -target=module.gke -auto-approve

echo "✅ Step 4: Kubeconfig 업데이트"
terraform apply -target=null_resource.update_kubeconfig -auto-approve

echo "✅ Step 5: Kafka GCE 배포 및 동적 ip 저장"
terraform apply -target=module.kafka_nodes -auto-approve

## 아래는 작업 편의에 도움이 될까 해서 추가해둔 것이고, 편하게 바꾸어 작업해주세요.
# echo "✅ Step 6: ELK GCE"
# terraform apply -target=module.elk_nodes -auto-approve

# echo "✅ Step 7: Click-House GCE"
# terraform apply -target=module.ch_nodes -auto-approve

# echo "✅ Step 8: Big-Qeury"
# terraform apply -target=module.bigquery -auto-approve

echo "✅ Step 9: 전체 모듈 확인 후 output 결과들을 원하는 경로로 이동"
terraform apply -auto-approve
terraform output -json > ../ansible/kafka/generated/kafka_nodes.json
# terraform output -json elk_node_ips | jq -r '.[]' > /tmp/elk_hosts.txt
# terraform output -json ch_node_ips | jq -r '.[]' > /tmp/ch_hosts.txt

echo "✅ Step 10: Kafka 인벤토리 생성 및 ansible로 카프카 배포"
cd ../ansible/kafka
bash generate_kafka_inventory.sh
bash deploy_kafka.sh

## 아래는 작업 편의에 도움이 될까 해서 추가해둔 것이고, 편하게 바꾸어 작업해주세요.
# echo "✅ Step 11: ELK 인벤토리 생성"
# cd ../elk
# bash generate_elk_inventory.sh
# ansible-playbook -i inventory_elk.ini elk.yml

# echo "✅ Step 12: click house 인벤토리 생성"
# cd ../clickhouse
# bash generate_ch_inventory.sh
# ansible-playbook -i inventory_ch.ini clickhouse.yml
