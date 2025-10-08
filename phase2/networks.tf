# Définition des réseaux via un bloc local
locals {
  networks = {
    subnet1 = {
      cidr_block = "10.0.1.0/24"
      az         = "us-east-1a"
    }
    subnet2 = {
      cidr_block = "10.0.2.0/24"
      az         = "us-east-1b"
    }
    subnet3 = {
      cidr_block = "10.0.3.0/24"
      az         = "us-east-1c"
    }
  }
}

# VPC principal
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-gw"
  }
}

# Table de routage
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public-route"
  }
}

# Sous-réseaux publics (3)
resource "aws_subnet" "subs" {
  for_each                 = local.networks
  vpc_id                   = aws_vpc.main.id
  cidr_block               = each.value.cidr_block
  availability_zone        = each.value.az
  map_public_ip_on_launch  = true

  tags = {
    Name = each.key
  }
}

# Association des sous-réseaux à la table de routage
resource "aws_route_table_association" "assoc" {
  for_each       = aws_subnet.subs
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}
