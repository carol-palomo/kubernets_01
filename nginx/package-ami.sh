#!/bin/bash

VERSAO=$(git describe --tags $(git rev-list --tags --max-count=1))

cd /var/lib/jenkins/workspace/PipelineInfra/nginx/terraform
RESOURCE_ID=$(terraform output aws_instance_id | cut -b 2- | rev | cut -b 2- | rev )

cd /var/lib/jenkins/workspace/PipelineInfra/nginx/terraform-ami
terraform init
TF_VAR_versao=$VERSAO TF_VAR_resource_id=$RESOURCE_ID terraform apply -auto-approve
