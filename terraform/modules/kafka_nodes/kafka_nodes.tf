# 카프카 노드 private key 생성
resource "tls_private_key" "kafka_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 카프카 노드 생성
resource "google_compute_instance" "kafka_nodes" {
  count        = var.kafka_node_count
  name         = "kafka-node-${count.index + 1}"
  machine_type = var.kafka_node_machine_type
  zone         = var.gcp_zone
  project      = var.gcp_project_id
  tags         = ["kafka-node"]

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
      size  = 30            # GB 단위, 최소 30 ~ 50 정도 필요하다고 함
      type  = "pd-balanced" # 더 고사양 필요 시 pd-ssd
    }
  }

  network_interface {
    network            = var.gcp_vpc_name
    subnetwork         = var.gcp_public_subnet_name
    subnetwork_project = var.gcp_project_id
    access_config {}
  }

  # private 키 할당
  metadata = {
    ssh-keys = "ubuntu:${tls_private_key.kafka_ssh.public_key_openssh}"
  }
}

# 로컬 파일에 ssh 키 저장
resource "local_file" "save_private_key" {
  content         = tls_private_key.kafka_ssh.private_key_pem
  filename        = "../../../ansible/kafka/generated/kafka_ansible.key"
  file_permission = "0600"
  depends_on      = [google_compute_instance.kafka_nodes]
}
