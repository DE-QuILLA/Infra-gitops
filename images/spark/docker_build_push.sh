# Docker 이미지 빌드
docker build -t coffeeisnan/custom_spark_image -f Dockerfile.spark .

# Docker Hub 푸시
docker push coffeeisnan/custom_spark_image
