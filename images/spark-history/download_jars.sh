#!/bin/bash

set -e

JAR_URL="https://storage.googleapis.com/hadoop-lib/gcs/gcs-connector-hadoop3-latest.jar"
OUTPUT_DIR="jars"
JAR_NAME="gcs-connector-hadoop3-latest.jar"

mkdir -p "$OUTPUT_DIR"

echo "🔍 Checking for existing JAR..."
if [[ -f "$OUTPUT_DIR/$JAR_NAME" ]]; then
    echo "✅ JAR already exists at $OUTPUT_DIR/$JAR_NAME"
else
    echo "⬇️  Downloading GCS connector..."
    curl -o "$OUTPUT_DIR/$JAR_NAME" "$JAR_URL"
    echo "✅ Downloaded to $OUTPUT_DIR/$JAR_NAME"
fi
