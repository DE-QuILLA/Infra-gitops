#!/bin/bash

# VPC 먼저 배포
cd ./terraform
terraform init
terraform apply
cd ../..
