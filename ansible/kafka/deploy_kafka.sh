#!/bin/bash
set -e

bash ./generate_kafka_inventory.sh
ansible-playbook kafka.yml # -vvv

ansible kafka -m shell -a "systemctl is-active kafka"
