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
    Lab  = "okd4"
  }
}

# Subnets

resource "aws_subnet" "public1_subnet" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = var.cidrs["public1"]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "public1"
    Lab  = "okd4"
  }
}

resource "aws_subnet" "private1_subnet" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = var.cidrs["private1"]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "private1"
    Lab  = "okd4"
  }
}

# Allocate EIP

resource "aws_eip" "nat_eip" {
  vpc = true
  
  tags = {
    Name = "nat_eip"
    Lab  = "okd4"
  }
}

# Internet gateway

resource "aws_internet_gateway" "lab_internet_gw" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = {
    Name = "lab_igw"
    Lab  = "okd4"
  }
}

# NAT gateway

resource "aws_nat_gateway" "lab_nat_gw" {
    allocation_id = aws_eip.nat_eip.id
    subnet_id     = aws_subnet.public1_subnet.id

    depends_on = [
        aws_internet_gateway.lab_internet_gw,
        aws_eip.nat_eip
    ]

    tags = {
        Name = "lab_nat"
        Lab  = "okd4"
    }
}

# Route tables

resource "aws_route_table" "lab_public_rt" {
  vpc_id = aws_vpc.lab_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab_internet_gw.id
  }

  tags = {
    Name = "lab_public"
    Lab  = "okd4"
  }
}

resource "aws_route_table" "lab_private_rt" {
  vpc_id = aws_vpc.lab_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.lab_nat_gw.id
  }

  tags = {
    Name = "lab_public"
    Lab  = "okd4"
  }
}

resource "aws_route_table_association" "public1_assoc" {
  subnet_id      = aws_subnet.public1_subnet.id
  route_table_id = aws_route_table.lab_public_rt.id
}

resource "aws_route_table_association" "private1_assoc" {
  subnet_id      = aws_subnet.private1_subnet.id
  route_table_id = aws_route_table.lab_private_rt.id
}



















#----- Set default SSH key pair -----

resource "aws_key_pair" "lab_auth" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

#----- Deploy Services -----

#module "svc" {
#  source      = "./svc"
#  aws_region  = var.aws_region
#  aws_profile = var.aws_profile
#  myIP        = "${chomp(data.http.myIP.body)}/32"
#  key_name    = var.key_name
#  vpc_id      = aws_vpc.lab_vpc.id
#  vpc_cidr    = var.vpc_cidr
#  vpc_subnet  = [aws_subnet.mgmt_subnet.id]
#}

#----- Deploy OpenShift -----

#module "okd" {
#  source           = "./okd"
#  aws_region       = var.aws_region
#  aws_profile      = var.aws_profile
#  myIP             = "${chomp(data.http.myIP.body)}/32"
#  key_name         = var.key_name
#  instance_type    = var.okd_instance_type
#  okd_master_count = var.okd_master_count
#  okd_node_count   = var.okd_node_count
#  vpc_id           = aws_vpc.lab_vpc.id
#  vpc_cidr         = var.vpc_cidr
#  vpc_subnet       = [aws_subnet.mgmt_subnet.id]
#}

