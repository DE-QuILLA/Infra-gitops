#!/bin/bash
set -e

NAMESPACE="kafka"
RELEASE_NAME="strimzi-kafka-operator"

echo "💣 1. Helm 릴리스 제거"
helm uninstall "$RELEASE_NAME" -n "$NAMESPACE" || true

echo "🧹 2. CRD 전체 제거"
for crd in $(kubectl get crd -o name | grep kafka.strimzi.io); do
  kubectl delete "$crd" || true
done

echo "🧹 3. 네임스페이스 제거"
kubectl delete ns "$NAMESPACE" --wait=true || true

echo "🧼 4. RoleBinding/ClusterRoleBinding/ClusterRole 전부 제거"
kubectl get rolebindings --all-namespaces | grep strimzi | awk '{print "kubectl delete rolebinding " $2 " -n " $1}' | bash || true
kubectl get clusterrolebindings | grep strimzi | awk '{print "kubectl delete clusterrolebinding " $1}' | bash || true
kubectl get clusterroles | grep strimzi | awk '{print "kubectl delete clusterrole " $1}' | bash || true
kubectl get roles --all-namespaces | grep strimzi | awk '{print "kubectl delete role " $2 " -n " $1}' | bash || true
kubectl delete rolebinding strimzi-cluster-operator -n kafka || true
kubectl delete rolebinding strimzi-cluster-operator-watched -n kafka || true
kubectl delete rolebinding strimzi-cluster-operator-entity-operator-delegation -n kafka || true

echo "🧹 5. WebhookConfiguration 정리"
kubectl get mutatingwebhookconfigurations | grep strimzi | awk '{print "kubectl delete mutatingwebhookconfiguration " $1}' | bash || true
kubectl get validatingwebhookconfigurations | grep strimzi | awk '{print "kubectl delete validatingwebhookconfiguration " $1}' | bash || true
 kubectl delete crd strimzipodsets.core.strimzi.io

echo "✅ 정리 완료"
