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

data "external" "okd_name" {
  program = ["bash", "scripts/get_okd_name.sh"]
}

data "external" "okd_masterigncert" {
  program = ["bash", "scripts/get_okd_masterigncert.sh"]
}

data "external" "okd_masterignloc" {
  program = ["bash", "scripts/get_okd_masterignloc.sh"]
}

data "external" "okd_workerigncert" {
  program = ["bash", "scripts/get_okd_workerigncert.sh"]
}

data "external" "okd_workerignloc" {
  program = ["bash", "scripts/get_okd_workerignloc.sh"]
}

variable "key_name" {
}

variable "public_key_path" {
}

variable "master_inst_type" {
}

variable "master_count" {
}

variable "worker_inst_type" {
}

variable "worker_count" {
}

variable "domain" {
}

