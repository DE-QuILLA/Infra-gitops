variable "kafka_node_count" {
  type    = number
  default = 5
}

variable "kafka_node_machine_type" {
  type    = string
  default = "e2-standard-4"
}

variable "gcp_project_id" {
  type    = string
  default = "de-quilla"
}

variable "gcp_zone" {
  type    = string
  default = "asia-northeast3-a"
}

variable "gcp_vpc_name" {
  type    = string
  default = "deq-vpc"
}

variable "gcp_public_subnet_name" {
  type    = string
  default = "deq-vpc-public"
}
