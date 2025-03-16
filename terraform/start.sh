#!/bin/bash

# 순서는 main.tf에서 보장
cd ./terraform
terraform init
terraform apply
