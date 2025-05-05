#!/bin/bash
set -e

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
JSON_FILE="${SCRIPT_DIR}/generated/kafka_nodes.json"
INVENTORY_FILE="${SCRIPT_DIR}/inventory_kafka.ini"

echo "📤 Kafka JSON 파일 읽어서 inventory_kafka.ini 생성 중"

# Extract IP arrays using jq
public_ips=($(jq -r '.kafka_node_public_ips.value[]' "$JSON_FILE"))
private_ips=($(jq -r '.kafka_node_private_ips.value[]' "$JSON_FILE"))

# Header
echo "[kafka]" > "$INVENTORY_FILE"

# Write each node line
for i in "${!public_ips[@]}"; do
  echo "node${i} ansible_host=${public_ips[$i]} private_ip=${private_ips[$i]} public_ip=${public_ips[$i]}" >> "$INVENTORY_FILE"
done

# Append vars
cat <<'EOF' >> "$INVENTORY_FILE"

[kafka:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=./generated/kafka_ansible.key

kafka_version=3.9.0
scala_version=2.13
kafka_install_dir=/opt/kafka
kafka_log_dirs=/var/lib/kafka-logs
kafka_process_roles=broker,controller
kafka_controller_port=9093
kafka_broker_port=9092
kafka_inter_broker_listener=PLAINTEXT
kafka_num_network_threads=8
kafka_num_io_threads=16
kafka_num_replica_fetchers=4
kafka_log_segment_bytes=1073741824
kafka_log_retention_hours=168
kafka_log_retention_check_interval_ms=300000
kafka_message_max_bytes=10485760
kafka_auto_create_topics=true
kafka_delete_topic_enable=true
kafka_unclean_leader_election_enable=false
EOF

echo "✅ inventory_kafka.ini 생성 완료: $INVENTORY_FILE"
