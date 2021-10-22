#!/bin/bash

cd terraform
terraform init
terraform fmt
terraform apply -auto-approve

echo  "Aguardando a criação das maquinas ..."
sleep 5

ID_M1=$(terraform output | grep 'k8s-master 1 -' | awk '{print $4;exit}')
ID_M1_DNS=$(terraform output | grep 'k8s-master 1 -' | awk '{print $9;exit}' | cut -b 8-)


echo "
[ec2-k8s-proxy]
$ID_M1_DNS

" > ../ansible/hosts



cd ../ansible
ansible-playbook -i hosts provisionar.yml -u ubuntu --private-key /home/ubuntu/.ssh/id_rsa
