#!/bin/bash

cd /var/lib/jenkins/workspace/PipelineInfra/nginx/
cd terraform
terraform init
terraform fmt
terraform apply -auto-approve

echo  "Aguardando a criação das maquinas ..."
sleep 5

ID_M1_DNS=$(terraform output | cut -b 23- | rev | cut -b 2- | rev)
echo ID_M1_DNS

echo "
[ec2-nginx]
$ID_M1_DNS

" > /var/lib/jenkins/workspace/PipelineInfra/nginx/ansible/hosts

echo  "Aguardando ..."
sleep 15

cd /var/lib/jenkins/workspace/PipelineInfra/nginx/ansible
ansible-playbook -i hosts provisionar.yml -u ubuntu --private-key /var/lib/jenkins/.ssh/id_rsa
