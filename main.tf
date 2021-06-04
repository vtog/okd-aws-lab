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
    Name = "${data.external.okd_name.result["name"]}_vpc"
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
    Name = "${data.external.okd_name.result["name"]}_public1"
    Lab  = "okd4"
  }
}

resource "aws_subnet" "private1_subnet" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = var.cidrs["private1"]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "${data.external.okd_name.result["name"]}_private1"
    Lab  = "okd4"
  }
}

# Allocate EIP

resource "aws_eip" "nat_eip" {
  vpc = true

  tags = {
    Name = "${data.external.okd_name.result["name"]}_nat_eip"
    Lab  = "okd4"
  }
}

# Internet gateway

resource "aws_internet_gateway" "lab_internet_gw" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = {
    Name = "${data.external.okd_name.result["name"]}_igw"
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
    Name = "${data.external.okd_name.result["name"]}_nat"
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
    Name = "${data.external.okd_name.result["name"]}_public"
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
    Name = "${data.external.okd_name.result["name"]}_private"
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

data "aws_route_tables" "lab_rts" {
  vpc_id = aws_vpc.lab_vpc.id
}

# Endpoints

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.lab_vpc.id
  service_name = "com.amazonaws.${var.aws_region}.s3"
  #route_table_ids = data.aws_route_tables.lab_rts.ids
  route_table_ids = ["${aws_route_table.lab_private_rt.id}", "${aws_route_table.lab_public_rt.id}"]

  tags = {
    Name = "${data.external.okd_name.result["name"]}_s3endpoint"
    Lab  = "okd4"
  }
}

# Network load balancers

resource "aws_lb" "ext_lb" {
  name               = "${data.external.okd_name.result["name"]}-extlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = aws_subnet.public1_subnet.*.id

  enable_deletion_protection = false

  tags = {
    Lab = "okd4"
  }
}

resource "aws_lb" "int_lb" {
  name               = "${data.external.okd_name.result["name"]}-intlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = aws_subnet.private1_subnet.*.id

  enable_deletion_protection = false

  tags = {
    Lab = "okd4"
  }
}

resource "aws_lb_target_group" "ext_tg_6443" {
  name                 = "${data.external.okd_name.result["name"]}-ext-6443"
  vpc_id               = aws_vpc.lab_vpc.id
  target_type          = "ip"
  protocol             = "TCP"
  port                 = 6443
  deregistration_delay = 60

  health_check {
    enabled             = true
    port                = 6443
    protocol            = "HTTPS"
    path                = "/readyz"
    interval            = 10
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

resource "aws_lb_listener" "ext_6443" {
  load_balancer_arn = aws_lb.ext_lb.arn
  port              = "6443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ext_tg_6443.arn
  }
}

resource "aws_lb_target_group" "int_tg_6443" {
  name                 = "${data.external.okd_name.result["name"]}-int-6443"
  vpc_id               = aws_vpc.lab_vpc.id
  target_type          = "ip"
  protocol             = "TCP"
  port                 = 6443
  deregistration_delay = 60

  health_check {
    enabled             = true
    port                = 6443
    protocol            = "HTTPS"
    path                = "/readyz"
    interval            = 10
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

resource "aws_lb_listener" "int_6443" {
  load_balancer_arn = aws_lb.int_lb.arn
  port              = "6443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.int_tg_6443.arn
  }
}

resource "aws_lb_target_group" "int_tg_22623" {
  name                 = "${data.external.okd_name.result["name"]}-int-22623"
  vpc_id               = aws_vpc.lab_vpc.id
  target_type          = "ip"
  protocol             = "TCP"
  port                 = 22623
  deregistration_delay = 60

  health_check {
    enabled             = true
    port                = 22623
    protocol            = "HTTPS"
    path                = "/healthz"
    interval            = 10
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

resource "aws_lb_listener" "int_22623" {
  load_balancer_arn = aws_lb.int_lb.arn
  port              = "22623"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.int_tg_22623.arn
  }
}

# Route53

resource "aws_route53_zone" "private_zone" {
  name = "${data.external.okd_name.result["name"]}.${var.domain}"

  vpc {
    vpc_id = aws_vpc.lab_vpc.id
  }

  tags = {
    Lab = "okd4"
  }
}

data "aws_route53_zone" "private" {
  name         = "${data.external.okd_name.result["name"]}.${var.domain}"
  private_zone = true

  depends_on = [
    aws_route53_zone.private_zone
  ]
}

resource "aws_route53_record" "api" {
  zone_id = data.aws_route53_zone.private.zone_id
  name    = "api.${data.aws_route53_zone.private.name}"
  type    = "A"

  alias {
    name                   = aws_lb.int_lb.dns_name
    zone_id                = aws_lb.int_lb.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "api-int" {
  zone_id = data.aws_route53_zone.private.zone_id
  name    = "api-int.${data.aws_route53_zone.private.name}"
  type    = "A"

  alias {
    name                   = aws_lb.int_lb.dns_name
    zone_id                = aws_lb.int_lb.zone_id
    evaluate_target_health = false
  }
}

data "aws_route53_zone" "public" {
  name         = var.domain
  private_zone = false
}

resource "aws_route53_record" "api-ext" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = "api.${data.external.okd_name.result["name"]}.${data.aws_route53_zone.public.name}"
  type    = "A"

  alias {
    name                   = aws_lb.ext_lb.dns_name
    zone_id                = aws_lb.ext_lb.zone_id
    evaluate_target_health = false
  }
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

module "okd" {
  source            = "./okd"
  aws_region        = var.aws_region
  aws_profile       = var.aws_profile
  myIP              = "${chomp(data.http.myIP.body)}/32"
  key_name          = var.key_name
  master_inst_type  = var.master_inst_type
  master_count      = var.master_count
  worker_inst_type  = var.worker_inst_type
  worker_count      = var.worker_count
  vpc_id            = aws_vpc.lab_vpc.id
  vpc_cidr          = var.vpc_cidr
  vpc_subnet        = [aws_subnet.public1_subnet.id, aws_subnet.private1_subnet.id]
  okd_name          = data.external.okd_name.result["name"]
  okd_masterignloc  = data.external.okd_masterignloc.result["masterignloc"]
  okd_masterigncert = data.external.okd_masterigncert.result["masterigncert"]
  okd_workerignloc  = data.external.okd_workerignloc.result["workerignloc"]
  okd_workerigncert = data.external.okd_workerigncert.result["workerigncert"]
  ext_tg_6443       = aws_lb_target_group.ext_tg_6443.arn
  int_tg_6443       = aws_lb_target_group.int_tg_6443.arn
  int_tg_22623      = aws_lb_target_group.int_tg_22623.arn
}

