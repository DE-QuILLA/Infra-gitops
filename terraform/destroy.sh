#!/bin/bash

# 테라폼으로 프로비저닝한 리소스를 내림
cd terraform
terraform destroy -auto-approve
