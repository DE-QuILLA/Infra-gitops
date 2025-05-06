helm repo add kafka-ui https://provectus.github.io/kafka-ui-charts
helm install kafka-ui kafka-ui/kafka-ui \
  --namespace kafka \
  --set kafka.clusters[0].name=my-cluster \
  --set kafka.clusters[0].bootstrapServers=my-cluster-kafka-bootstrap.kafka.svc:9092 \
  --set service.type=LoadBalancer
  
