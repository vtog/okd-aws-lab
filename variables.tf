variable "aws_profile" {
}

variable "aws_region" {
}

variable "vpc_cidr" {
}

data "aws_availability_zones" "available" {
}

variable "cidrs" {
  type = map(string)
}

data "http" "myIP" {
  url = "http://ipv4.icanhazip.com"
}

variable "key_name" {
}

variable "public_key_path" {
}

variable "okd_instance_type" {
}

variable "okd_master_count" {
}

variable "okd_node_count" {
}

