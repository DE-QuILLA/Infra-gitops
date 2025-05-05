variable "gcp_vpc_name" {
  type    = string
  default = "deq-vpc"
}

variable "gcp_public_subnet_name" {
  type    = string
  default = "deq-vpc-public"
}

variable "gcp_public_subnet_cidr" {
  type    = string
  default = "10.10.0.0/16"
}

variable "gcp_region" {
  type    = string
  default = "asia-northeast3" # 서울 리전
}
