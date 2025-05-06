#!/bin/bash
set -e

# 다운로드 디렉토리
mkdir -p jars && cd jars

# Kafka + Spark Streaming
wget -O spark-sql-kafka-0-10_2.12-3.5.1.jar \
  https://repo1.maven.org/maven2/org/apache/spark/spark-sql-kafka-0-10_2.12/3.5.1/spark-sql-kafka-0-10_2.12-3.5.1.jar

wget -O spark-token-provider-kafka-0-10_2.12-3.5.1.jar \
  https://repo1.maven.org/maven2/org/apache/spark/spark-token-provider-kafka-0-10_2.12/3.5.1/spark-token-provider-kafka-0-10_2.12-3.5.1.jar

wget -O spark-streaming_2.12-3.5.1.jar \
  https://repo1.maven.org/maven2/org/apache/spark/spark-streaming_2.12/3.5.1/spark-streaming_2.12-3.5.1.jar

wget -O kafka-clients-3.4.1.jar \
  https://repo1.maven.org/maven2/org/apache/kafka/kafka-clients/3.4.1/kafka-clients-3.4.1.jar

# GCS connector (Hadoop 3.x 기반)
wget -O gcs-connector-hadoop3-2.2.0.jar \
  https://repo1.maven.org/maven2/com/google/cloud/bigdataoss/gcs-connector/hadoop3-2.2.0/gcs-connector-hadoop3-2.2.0.jar

# 기타 종속성
wget -O commons-pool2-2.11.1.jar \
  https://repo1.maven.org/maven2/org/apache/commons/commons-pool2/2.11.1/commons-pool2-2.11.1.jar

wget -O jsr305-3.0.0.jar \
  https://repo1.maven.org/maven2/com/google/code/findbugs/jsr305/3.0.0/jsr305-3.0.0.jar

# GCS 의존성 JARs
wget -O google-api-client-1.32.1.jar \
  https://repo1.maven.org/maven2/com/google/api-client/google-api-client/1.32.1/google-api-client-1.32.1.jar

wget -O google-http-client-1.40.1.jar \
  https://repo1.maven.org/maven2/com/google/http-client/google-http-client/1.40.1/google-http-client-1.40.1.jar

wget -O google-http-client-gson-1.40.1.jar \
  https://repo1.maven.org/maven2/com/google/http-client/google-http-client-gson/1.40.1/google-http-client-gson-1.40.1.jar

wget -O google-oauth-client-1.32.1.jar \
  https://repo1.maven.org/maven2/com/google/oauth-client/google-oauth-client/1.32.1/google-oauth-client-1.32.1.jar

echo "✅ All required JARs downloaded into ./jars"
