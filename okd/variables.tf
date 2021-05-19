variable "aws_region" {
}

variable "aws_profile" {
}

variable "myIP" {
}

variable "key_name" {
}

variable "instance_type" {
}

variable "okd_master_count" {
}

variable "okd_node_count" {
}

variable "vpc_id" {
}

variable "vpc_cidr" {
}

variable "vpc_subnet" {
  type = list(string)
}
