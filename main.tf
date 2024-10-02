terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
    github = {
        source = "integrations/github"
        version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "github" {
  token = var.token
}

# GITHUB

variable "git-token" {
  default = "xxxxxxx"
}

variable "git-name" {
  default = "xxxxxxxx"
}

variable "files" {
  default = ["bookstore-api.py", "docker-compose.yml", "requirements.txt", "Dockerfile"]
}

resource "github_repository" "myrepo" {
  name = "docker-bookstore-api"
  visibility = "private"
  auto_init = true
}

resource "github_branch_default" "main" {
  branch = "main"
  repository = github_repository.myrepo.name
}

resource "github_repository_file" "api-files" {
  for_each = toset(var.files)
  content = file(each.value)
  file = each.value
  repository = github_repository.myrepo.main
  branch = "main"
  overwrite_on_create = true
  commit_message = "initial commit by terraform"
}

# AWS

# Network & Security Group

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_security_group" "allow-http" {
  name = "allow-http"
  vpc_id = aws_default_vpc.default.id
  tags = {
    Name = "allow-http"
    }
}

resource "aws_security_group" "allow-ssh" {
  name = "allow-ssh"
  vpc_id = aws_default_vpc.default.id
  tags = {
    Name = "allow-ssh"
  }
}

resource "aws_vpc_security_group_ingress_rule" "http-ingress" {
  security_group_id = aws_security_group.allow-http.id
  cidr_ipv4 = aws_default_vpc.default.cidr_block
  from_port = 80
  to_port = 80
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ssh-ingress" {
  security_group_id = aws_security_group.allow-ssh.id
  cidr_ipv4 = aws_default_vpc.default.cidr_block
  from_port = 22
  to_port = 22
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "http-egress" {
  security_group_id = aws_security_group.allow-http.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1"
  tags = {
    Name = "http-egress"
  }
}

resource "aws_vpc_security_group_egress_rule" "ssh-egress" {
  security_group_id = aws_security_group.allow-ssh.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1"
  tags = {
    Name = "ssh-egress"
  }
}


# EC2
variable "key-name" {
  default = "core"
}

data "aws_ami" "default-ami" {
  most_recent = true
  owners = [ "amazon" ]

  filter {
    name = "virtualization-type"
    values = [ "hvm" ]
  }

  filter {
    name = "architecture"
    values = [ "x86_64" ]
  }

  filter {
    name = "name"
    values = [ "al2023-ami-2023*" ]
  }
}

resource "aws_instance" "amazon-2003-ami" {
  ami = data.aws_ami.default-ami.id
  instance_type = "t3.medium"
  key_name = var.key-name
  vpc_security_group_ids = [ aws_security_group.allow-http.id, aws_security_group.allow-ssh.id ]
  user_data = templatefile("user-data.sh", {user-data-git-token = var.git-token, user-data-git-name = var.git-name})
  depends_on = [ github_repository.myrepo, github_repository_file.api-files ]
  tags = {
    Name = "default-amazon-ami"
  }
}



