#!/bin/bash

set -e

REPO="docker.io/coffeeisnan"
IMAGE_NAME="spark-history-server"
TAG="latest"

echo "📦 Downloading GCS connector..."
mkdir -p jars
wget -O jars/gcs-connector-hadoop3-latest.jar https://storage.googleapis.com/hadoop-lib/gcs/gcs-connector-hadoop3-latest.jar

echo "🐳 Building Docker image..."
docker build -t "$REPO/$IMAGE_NAME:$TAG" -f Dockerfile.spark-history .

echo "📤 Pushing to Docker Hub..."
docker push "$REPO/$IMAGE_NAME:$TAG"

echo "✅ Done: $REPO/$IMAGE_NAME:$TAG"
