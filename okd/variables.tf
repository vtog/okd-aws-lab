variable "aws_region" {
}

variable "aws_profile" {
}

variable "myIP" {
}

variable "key_name" {
}

variable "master_inst_type" {
}

variable "master_count" {
}

variable "worker_inst_type" {
}

variable "worker_count" {
}

variable "vpc_id" {
}

variable "vpc_cidr" {
}

variable "vpc_subnet" {
  type = list(string)
}

variable "private_domain" {
}

variable "private_domain_id" {
}

variable "public_domain" {
}

variable "public_domain_id" {
}

variable "cluster_name" {
}

variable "okd_name" {
}

variable "ext_tg_6443" {
}

variable "int_tg_6443" {
}

variable "int_tg_22623" {
}

variable "okd_ips" {
  default = {
    "0" = "10.1.1.20"
    "1" = "10.1.1.21"
    "2" = "10.1.1.22"
    "3" = "10.1.1.23"
    "4" = "10.1.1.24"
    "5" = "10.1.1.25"
  }
}

