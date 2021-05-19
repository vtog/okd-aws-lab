provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

#----- Create VPC -----

resource "aws_vpc" "lab_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "lab_vpc"
    Lab  = "Containers"
  }
}

# Internet gateway

resource "aws_internet_gateway" "lab_internet_gateway" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = {
    Name = "lab_igw"
    Lab  = "Containers"
  }
}

# Route tables

resource "aws_route_table" "lab_public_rt" {
  vpc_id = aws_vpc.lab_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab_internet_gateway.id
  }

  tags = {
    Name = "lab_public"
    Lab  = "Containers"
  }
}

# Subnets

resource "aws_subnet" "mgmt_subnet" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = var.cidrs["mgmt"]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "lab_mgmt"
    Lab  = "Containers"
  }
}

resource "aws_subnet" "okd_subnet" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = var.cidrs["okd"]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "lab_okd"
    Lab  = "Containers"
  }
}

resource "aws_route_table_association" "lab_mgmt_assoc" {
  subnet_id      = aws_subnet.mgmt_subnet.id
  route_table_id = aws_route_table.lab_public_rt.id
}

resource "aws_route_table_association" "lab_okd_assoc" {
  subnet_id      = aws_subnet.okd_subnet.id
  route_table_id = aws_route_table.lab_public_rt.id
}

#----- Set default SSH key pair -----

resource "aws_key_pair" "lab_auth" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

#----- Deploy Services -----

module "svc" {
  source        = "./svc"
  aws_region    = var.aws_region
  aws_profile   = var.aws_profile
  myIP          = "${chomp(data.http.myIP.body)}/32"
  key_name      = var.key_name
  vpc_id        = aws_vpc.lab_vpc.id
  vpc_cidr      = var.vpc_cidr
  vpc_subnet    = [aws_subnet.mgmt_subnet.id]
}

#----- Deploy OpenShift -----

module "okd" {
  source           = "./okd"
  aws_region       = var.aws_region
  aws_profile      = var.aws_profile
  myIP             = "${chomp(data.http.myIP.body)}/32"
  key_name         = var.key_name
  instance_type    = var.okd_instance_type
  okd_master_count = var.okd_master_count
  okd_node_count   = var.okd_node_count
  vpc_id           = aws_vpc.lab_vpc.id
  vpc_cidr         = var.vpc_cidr
  vpc_subnet       = [aws_subnet.okd_subnet.id]
}
