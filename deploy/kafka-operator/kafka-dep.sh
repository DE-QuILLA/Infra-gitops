helm install strimzi-kafka-operator-new strimzi/strimzi-kafka-operator \
  -f kafka-operator-values.yaml \
  --namespace kafka-new \
  --create-namespace \
  --set watchAnyNamespace=false \
  --set watchNamespaces[0]=kafka-new \
  --set kafkaKraft=true \
  --set defaultKafkaVersion="4.0.0" \
  --wait
