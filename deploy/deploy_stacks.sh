#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# [1] airflow 네임스페이스 - CloudSQL Proxy + Airflow 배포
echo -e "\n❗ Airflow 배포 시작!\n"
chmod +x "$SCRIPT_DIR/airflow/deploy_airflow.sh"
bash "$SCRIPT_DIR/airflow/deploy_airflow.sh"
echo -e "\n✅ Airflow 배포 완료!\n"

# [2] spark 네임스페이스 - spark-connect, spark-history-server, spark-operator 배포
echo -e "\n❗ Spark 배포 시작!\n"
chmod +x "$SCRIPT_DIR/spark/deploy_spark.sh"
bash "$SCRIPT_DIR/spark/deploy_spark.sh"
echo -e "\n✅ Spark 배포 완료!\n"

# [3] kafka-1 네임스페이스 - strimizi kafka operator + kafka cluster, kafka-ui 배포
echo -e "\n❗ Kafka 배포 시작!\n"
chmod +x "$SCRIPT_DIR/kafka-operator/deploy_kafka.sh"
bash "$SCRIPT_DIR/kafka-operator/deploy_kafka.sh"
echo -e "\n✅ Kafka 배포 완료!\n"

# [4] elk-ns 네임 스페이스 - ELK 스택 배포
echo -e "\n❗ ELK stack 배포 시작!\n"
chmod +x "$SCRIPT_DIR/elk/elk_deploy.sh"
bash "$SCRIPT_DIR/elk/elk_deploy.sh"
echo -e "\n✅ ELK stack 배포 완료!\n"

# [5] monitoring 네임 스페이스 - 프로메테우스 + 그라파나 배포, kafka exporter 배포
echo -e "\n❗ Monitoring stacks 배포 시작!\n"
chmod +x "$SCRIPT_DIR/monitoring/deploy_monitoring.sh"
bash "$SCRIPT_DIR/monitoring/deploy_monitoring.sh"
echo -e "\n✅ Monitoring stacks 배포 완료!\n"

echo -e "\n🎉 모든 컴포넌트 최종 배포 완료!\n"
