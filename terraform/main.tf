provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "master" {
  ami                     = "ami-09e67e426f25ce0d7"
  instance_type           = "t2.medium"
  key_name                = "id_rsa" # key chave publica cadastrada na AWS 
  vpc_security_group_ids  = ["${aws_security_group.kubernetes_master.id}"]
  subnet_id               =  "subnet-0ab487dbac2dcfa24"
  associate_public_ip_address = true
  
  root_block_device {
    volume_size           = "8"
    volume_type           = "gp2"
    encrypted             = true
    kms_key_id            = "f48a0432-3f72-4888-9b31-8bdf1c121a4c"
    delete_on_termination = true
  }

  tags = {
    Name = "k8s_master-carol"
  }
}

resource "aws_instance" "worker" {
  count = 2
  ami                     = "ami-09e67e426f25ce0d7"
  instance_type           = "t2.micro"
  key_name                = "id_rsa" # key chave publica cadastrada na AWS 
  vpc_security_group_ids  = ["${aws_security_group.kubernetes_workers.id}"]
  subnet_id               =  "subnet-05880ea9006199004"
  associate_public_ip_address = true
  
  root_block_device {
    volume_size           = "8"
    volume_type           = "gp2"
    encrypted             = true
    kms_key_id            = "f48a0432-3f72-4888-9b31-8bdf1c121a4c"
    delete_on_termination = true
  }

  tags = {
    Name = "k8s_worker${count.index}-carol"
  }
}


resource "aws_security_group" "kubernetes_master" {
  name        = "allow_ssh_1_vpc_terraform_carol"
  description = "Allow SSH inbound traffic criado pelo terraform VPC"
  vpc_id = "vpc-0304dcb48c5e67fa0"

  ingress = [
    {
      description      = "SSH from VPC"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids = null,
      security_groups: null,
      self: null
    },
    {
      description      = "Libera porta kubernetes"
      from_port        = 6443
      to_port          = 6443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids = null,
      security_groups = null,
      self            = null
    }
  ]

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids = null,
      security_groups: null,
      self: null,
      description: "Libera dados da rede interna"
    }
  ]

  tags = {
    Name = "kubernetes_master"
  }
}

resource "aws_security_group" "kubernetes_workers" {
  name        = "acessos_workers"
  description = "acessos_workers inbound traffic"

  ingress = [
    {
      description      = "SSH from VPC"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids = null,
      security_groups: null,
      self: null
    },
  ]

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"],
      prefix_list_ids = null,
      security_groups: null,
      self: null,
      description: "Libera dados da rede interna"
    }
  ]

  tags = {
    Name = "kubernetes_workers"
  }
}

output "k8s_master_ssh" {
  value = aws_instance.master.public_dns
}

output "k8s_worker0_ssh" {
  value = aws_instance.worker[0].public_dns
}

output "k8s_worker1_ssh" {
  value = aws_instance.worker[1].public_dns
}
