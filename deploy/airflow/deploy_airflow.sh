#!/bin/bash
set -e

# airflow 네임스페이스 - CloudSQL Proxy + Airflow 배포 쉘 스크립트
echo "🖥️ Airflow 네임스페이스 생성"
kubectl create namespace airflow || true
echo "✅ airflow 네임 스페이스 생성 완료!"

echo "🖥️ Airflow 용 Cloud SQL Proxy 배포"
kubectl create secret generic gcp-key --from-file=key.json=./key.json -n airflow || true
kubectl apply -f proxy-deployment.yaml
echo "✅ Cloud SQL Proxy 배포 완료!"

echo "🖥️ Airflow 배포"
helm repo add apache-airflow https://airflow.apache.org
helm repo update
helm upgrade airflow apache-airflow/airflow --install -f airflow-values.yaml -n airflow
echo "✅ Airflow 배포 완료!"

echo "🖥️ Airflow worker의 cluster-role 설정"
kubectl apply -f airflow-cluster-role.yaml
echo "✅ Airflow worker의 cluster-role 설정 완료!"

echo "🎉 airflow 네임스페이스 내 모든 리소스 배포 완료!"
