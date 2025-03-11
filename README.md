# Infra-gitops

- 팀프로젝트의 인프라, 깃 옵스 관련 코드들 모음


### 1. 인프라 설정하기

##### 1 - 1. 필요 목록

- terraform: 1.11.1

```sh
# HashiCorp GPG 키 추가
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg

# HashiCorp 저장소 추가
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Terraform 설치
sudo apt-get update && sudo apt-get install terraform -y

# 버전 확인
terraform -version
```

- gcloud: 0.18.3

```sh
pip install -r requirements-dev.txt
```

- kubectl 설치

```sh
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl

# Google Cloud의 GPG 키 추가
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg \
  https://packages.cloud.google.com/apt/doc/apt-key.gpg

# Kubernetes 저장소 추가
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] \
  https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# 설치
sudo apt update
sudo apt install -y kubectl

# 버전 확인
kubectl version --client
```


##### 1 - 2. 클라우드 인프라 프로비저닝하기

- 인프라 띄우기

```sh
./start.sh
```

- 인프라 내리기

```sh
./destroy.sh
```

sdf
sdfsdfsdf
