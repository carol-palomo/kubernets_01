provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "nginx" {
  ami                     = "ami-09e67e426f25ce0d7"
  instance_type           = "t2.micro"
  key_name                = "id_rsa" # key chave publica cadastrada na AWS 
  vpc_security_group_ids  = ["${aws_security_group.acessos_nginx.id}"]
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
    Name = "nginx-carol"
  }
}

resource "aws_security_group" "acessos_nginx" {
  name        = "acessos_nginx"
  description = "acessos inbound traffic"

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
      description      = "Acesso HTTPS"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids = null,
      security_groups: null,
      self: null
    },
    {
      description      = "Acesso HTTP"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids = null,
      security_groups: null,
      self: null
    }
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
    Name = "allow_ssh"
  }
}

# terraform refresh para mostrar o ssh
output "aws_instance_e_ssh" {
  value = [
    aws_instance.maquina_nginx.public_ip,
    "sudo ssh -i /root/.ssh/id_rsa ubuntu@${aws_instance.maquina_nginx.public_dns}"
  ]
}
