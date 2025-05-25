echo -e "\n Starting ClickHouse deployment..."

CLICKHOUSE_NAMESPACE="test-clickhouse"
CLICKHOUSE_RELEASE_NAME="ch-test"
CLICKHOUSE_SECRET_NAME="test-clickhouse-password"  # pragma: allowlist secret

kubectl create ns "$CLICKHOUSE_NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

if ! kubectl get secret "$CLICKHOUSE_SECRET_NAME" -n "$CLICKHOUSE_NAMESPACE" >/dev/null 2>&1; then
  echo "[$CLICKHOUSE_SECRET_NAME] secret does not exist. Aborting deployment."
  exit 1
fi

helm repo add altinity https://altinity.github.io/helm-charts || true
helm repo update

helm upgrade --install "$CLICKHOUSE_RELEASE_NAME" altinity/clickhouse \
  -f "./clickhouse/clickhouse-values.yaml" \
  -n "$CLICKHOUSE_NAMESPACE" \
  --wait

wait_for_pods "$CLICKHOUSE_NAMESPACE"
