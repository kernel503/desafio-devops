terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.60.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "test_k8s" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "test-k8s"
  }
}

resource "aws_subnet" "test_k8s" {
  vpc_id                  = aws_vpc.test_k8s.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = false

  tags = {
    Name = "test-k8s-subnet-private"
  }
}

resource "aws_internet_gateway" "test_k8s" {
  vpc_id = aws_vpc.test_k8s.id

  tags = {
    Name = "test-k8s-igw"
  }
}

resource "aws_route_table" "test_k8s" {
  vpc_id = aws_vpc.test_k8s.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test_k8s.id
  }

  tags = {
    Name = "test-k8s-rt"
  }
}

resource "aws_route_table_association" "test_k8s" {
  subnet_id      = aws_subnet.test_k8s.id
  route_table_id = aws_route_table.test_k8s.id
}

resource "aws_security_group" "test_k8s" {
  name        = "test-k8s-sg"
  description = "Security group para cluster K8s"
  vpc_id      = aws_vpc.test_k8s.id

  ingress {
    description = "All internal traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "test-k8s-sg"
  }
}

resource "aws_security_group" "kube_api_server" {
  name        = "kube-api-server-sg"
  description = "Permite trafico TCP 6443 hacia el Kube API Server"
  vpc_id      = aws_vpc.test_k8s.id

  ingress {
    description = "kube-api-server"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "kube-api-server-sg"
    Role = "kube-api-server"
  }
}

resource "aws_security_group" "public_access" {
  name        = "public-access-sg"
  description = "Permite trafico SSH, HTTP y HTTPS publico"
  vpc_id      = aws_vpc.test_k8s.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public-access-sg"
  }
}

resource "aws_key_pair" "test_k8s" {
  key_name   = "test-k8s-key"
  public_key = file(var.public_key)
}

locals {
  instances = {
    kmaster1 = { public = true }
    worker1  = { public = true }
  }
}

resource "aws_instance" "k8s_nodes" {
  for_each = local.instances

  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.test_k8s.id
  associate_public_ip_address = each.value.public
  source_dest_check           = false
  key_name                    = aws_key_pair.test_k8s.key_name
  user_data                   = file("scripts/k8s-common.sh")

  vpc_security_group_ids = each.key == "kmaster1" ? [
    aws_security_group.test_k8s.id,
    aws_security_group.kube_api_server.id,
    aws_security_group.public_access.id
  ] : [
    aws_security_group.test_k8s.id,
    aws_security_group.public_access.id
  ]

  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp3"
    encrypted   = true

    tags = {
      Name = "${each.key}-disk"
    }
  }

  tags = {
    Name = each.key
    Role = each.key == "kmaster1" ? "master" : "worker"
  }
}