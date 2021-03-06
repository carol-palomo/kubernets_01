provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "master" {
  count = 3
  ami                     = "ami-09e67e426f25ce0d7"
  instance_type           = "t2.large"
  key_name                = "id_rsa" # key chave publica cadastrada na AWS 
  vpc_security_group_ids  = ["${aws_security_group.kubernetes_master.id}", "${aws_security_group.kubernetes_geral.id}"]
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
    Name = "k8s_master${count.index}-carol"
  }
}

resource "aws_instance" "worker" {
  count = 3
  ami                     = "ami-09e67e426f25ce0d7"
  instance_type           = "t2.medium"
  key_name                = "id_rsa" # key chave publica cadastrada na AWS 
  vpc_security_group_ids  = ["${aws_security_group.kubernetes_workers.id}", "${aws_security_group.kubernetes_geral.id}"]
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

resource "aws_instance" "proxy" {
  ami                     = "ami-09e67e426f25ce0d7"
  instance_type           = "t2.micro"
  key_name                = "id_rsa" # key chave publica cadastrada na AWS 
  vpc_security_group_ids  = ["${aws_security_group.kubernetes_workers.id}", "${aws_security_group.kubernetes_geral.id}"]
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
    Name = "k8s_proxy-carol"
  }
}


resource "aws_security_group" "kubernetes_master" {
  name        = "kubernetes_master"
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
  name        = "kubernetes_workers"
  description = "acessos_workers inbound traffic"
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

resource "aws_security_group" "kubernetes_geral" {
  name        = "kubernetes_geral"
  description = "all tcp entre master e nodes do kubernetes"
  vpc_id = "vpc-0304dcb48c5e67fa0"

  ingress = [
    {
      description      = "all tcp entre master e nodes do kubernetes"
      from_port        = 0
      to_port          = 0
      protocol         = -1
      cidr_blocks      = null
      ipv6_cidr_blocks = null,
      prefix_list_ids = null,
      security_groups: ["${aws_security_group.kubernetes_master.id}", "${aws_security_group.kubernetes_workers.id}"]
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
    Name = "kubernetes_geral"
  }
}

output "k8s-masters" {
  value = [
    for key, item in aws_instance.master :
      "k8s-master ${key+1} - ${item.private_ip} - ssh -i ~/Desktop/devops/treinamentoItau ubuntu@${item.public_dns} -o ServerAliveInterval=60"
  ]
}

  output "output-k8s_workers" {
  value = [
    for key, item in aws_instance.worker :
      "k8s-workers ${key+1} - ${item.private_ip} - ssh -i ~/Desktop/devops/treinamentoItau ubuntu@${item.public_dns} -o ServerAliveInterval=60"
  ]
}

output "output-k8s_proxy" {
  value = [
    "k8s_proxy - ${aws_instance.proxy.private_ip} - ssh -i ~/Desktop/devops/treinamentoItau ubuntu@${aws_instance.k8s_proxy.public_dns} -o ServerAliveInterval=60"
  ]
}
