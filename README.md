# Infra-gitops

- 팀프로젝트의 인프라, 깃 옵스 관련 코드들 모은 레포


---

### 1. 인프라 설정하기

##### 1 - 1. 필요 종속성 설치하기

- terraform: 1.11.1 (ubuntu 기준 설치방법)

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

- 진행할 우분투 OS 버전정보

```sh
lsb_release -a  # 명령어, 이 아래부터 출력
#########################################
No LSB modules are available.
Distributor ID: Ubuntu
Description:    Ubuntu 22.04.5 LTS
Release:        22.04
Codename:       jammy
```

- gcloud: 0.18.3

```sh
pip install -r requirements-dev.txt
pre-commit install  # 프리커밋
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

# kubectl version --client (명령어)
# Client Version: v1.32.3
# Kustomize Version: v5.5.0
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
