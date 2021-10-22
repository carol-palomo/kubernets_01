#!/bin/bash

cd terraform
terraform init
terraform fmt
terraform apply -auto-approve

echo  "Aguardando a criação das maquinas ..."
sleep 5

ID_M1_DNS=$(terraform output | cut -b 23- | rev | cut -b 2- | rev)


echo "
[ec2-nginx]
$ID_M1_DNS

" > ../ansible/hosts

echo  "Aguardando ..."
sleep 5

cd ../ansible
ansible-playbook -i hosts provisionar.yml -u ubuntu --private-key /home/ubuntu/.ssh/id_rsa
