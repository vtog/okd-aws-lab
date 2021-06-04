data "aws_ami" "fcos_ami" {
  most_recent = true
  owners      = ["125523088429"]

  filter {
    name   = "name"
    values = ["fedora-coreos-34*"]
  }

  filter {
    name   = "description"
    values = ["Fedora CoreOS stable*"]
  }
}

# Security Groups

resource "aws_security_group" "okd_bootstrap_sg" {
  name   = "${var.okd_name}_bootstrap_sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.myIP]
  }

  ingress {
    from_port   = 19531
    to_port     = 19531
    protocol    = "tcp"
    cidr_blocks = [var.myIP]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.okd_name}_bootstrap_sg"
    Lab  = "okd4"
  }
}

resource "aws_security_group" "okd_master_sg" {
  name   = "${var.okd_name}_master_sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = 22623
    to_port     = 22623
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.okd_name}_master_sg"
    Lab  = "okd4"
  }
}

resource "aws_security_group" "okd_worker_sg" {
  name   = "${var.okd_name}_worker_sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.okd_name}_worker_sg"
    Lab  = "okd4"
  }
}

resource "aws_security_group_rule" "MasterIngressEtcd" {
  type                     = "ingress"
  description              = "etcd"
  from_port                = 2379
  to_port                  = 2380
  protocol                 = "tcp"
  security_group_id        = aws_security_group.okd_master_sg.id
  source_security_group_id = aws_security_group.okd_master_sg.id
}

resource "aws_security_group_rule" "MasterIngressVxlan" {
  type                     = "ingress"
  description              = "vxlan"
  from_port                = 4789
  to_port                  = 4789
  protocol                 = "udp"
  security_group_id        = aws_security_group.okd_master_sg.id
  source_security_group_id = aws_security_group.okd_master_sg.id
}

resource "aws_security_group_rule" "MasterIngressWorkerVxlan" {
  type                     = "ingress"
  description              = "vxlan"
  from_port                = 4789
  to_port                  = 4789
  protocol                 = "udp"
  security_group_id        = aws_security_group.okd_master_sg.id
  source_security_group_id = aws_security_group.okd_worker_sg.id
}

resource "aws_security_group_rule" "MasterIngressGeneve" {
  type                     = "ingress"
  description              = "geneve"
  from_port                = 6081
  to_port                  = 6081
  protocol                 = "udp"
  security_group_id        = aws_security_group.okd_master_sg.id
  source_security_group_id = aws_security_group.okd_master_sg.id
}

resource "aws_security_group_rule" "MasterIngressWorkerGeneve" {
  type                     = "ingress"
  description              = "geneve"
  from_port                = 6081
  to_port                  = 6081
  protocol                 = "udp"
  security_group_id        = aws_security_group.okd_master_sg.id
  source_security_group_id = aws_security_group.okd_worker_sg.id
}

resource "aws_security_group_rule" "MasterIngressIpsecIke" {
  type                     = "ingress"
  description              = "IPsec IKE"
  from_port                = 500
  to_port                  = 500
  protocol                 = "udp"
  security_group_id        = aws_security_group.okd_master_sg.id
  source_security_group_id = aws_security_group.okd_master_sg.id
}

resource "aws_security_group_rule" "MasterIngressIpsecNat" {
  type                     = "ingress"
  description              = "IPsec NAT-T"
  from_port                = 4500
  to_port                  = 4500
  protocol                 = "udp"
  security_group_id        = aws_security_group.okd_master_sg.id
  source_security_group_id = aws_security_group.okd_master_sg.id
}

resource "aws_security_group_rule" "MasterIngressIpsecEsp" {
  type                     = "ingress"
  description              = "IPsec ESP"
  from_port                = 0
  to_port                  = 0
  protocol                 = 50
  security_group_id        = aws_security_group.okd_master_sg.id
  source_security_group_id = aws_security_group.okd_master_sg.id
}

resource "aws_security_group_rule" "MasterIngressWorkerIpsecIke" {
  type                     = "ingress"
  description              = "IPsec IKE"
  from_port                = 500
  to_port                  = 500
  protocol                 = "udp"
  security_group_id        = aws_security_group.okd_master_sg.id
  source_security_group_id = aws_security_group.okd_worker_sg.id
}

resource "aws_security_group_rule" "MasterIngressWorkerIpsecNat" {
  type                     = "ingress"
  description              = "IPsec NAT-T"
  from_port                = 4500
  to_port                  = 4500
  protocol                 = "udp"
  security_group_id        = aws_security_group.okd_master_sg.id
  source_security_group_id = aws_security_group.okd_worker_sg.id
}

resource "aws_security_group_rule" "MasterIngressWorkerIpsecEsp" {
  type                     = "ingress"
  description              = "IPsec ESP"
  from_port                = 0
  to_port                  = 0
  protocol                 = 50
  security_group_id        = aws_security_group.okd_master_sg.id
  source_security_group_id = aws_security_group.okd_worker_sg.id
}

resource "aws_security_group_rule" "MasterIngressInternal" {
  type                     = "ingress"
  description              = "Internal cluster communication"
  from_port                = 9000
  to_port                  = 9999
  protocol                 = "tcp"
  security_group_id        = aws_security_group.okd_master_sg.id
  source_security_group_id = aws_security_group.okd_master_sg.id
}

resource "aws_security_group_rule" "MasterIngressWorkerInternal" {
  type                     = "ingress"
  description              = "Internal cluster communication"
  from_port                = 9000
  to_port                  = 9999
  protocol                 = "tcp"
  security_group_id        = aws_security_group.okd_master_sg.id
  source_security_group_id = aws_security_group.okd_worker_sg.id
}

resource "aws_security_group_rule" "MasterIngressInternalUDP" {
  type                     = "ingress"
  description              = "Interncal cluster communication"
  from_port                = 9000
  to_port                  = 9999
  protocol                 = "udp"
  security_group_id        = aws_security_group.okd_master_sg.id
  source_security_group_id = aws_security_group.okd_master_sg.id
}

resource "aws_security_group_rule" "MasterIngressWorkerInternalUDP" {
  type                     = "ingress"
  description              = "Internal cluster communication"
  from_port                = 9000
  to_port                  = 9999
  protocol                 = "udp"
  security_group_id        = aws_security_group.okd_master_sg.id
  source_security_group_id = aws_security_group.okd_worker_sg.id
}

resource "aws_security_group_rule" "MasterIngressKube" {
  type                     = "ingress"
  description              = "Kubernetes kubelet, scheduler and controller manager"
  from_port                = 10250
  to_port                  = 10259
  protocol                 = "tcp"
  security_group_id        = aws_security_group.okd_master_sg.id
  source_security_group_id = aws_security_group.okd_master_sg.id
}

resource "aws_security_group_rule" "MasterIngressWorkerKube" {
  type                     = "ingress"
  description              = "Kubernetes kubelet, scheduler and controller manager"
  from_port                = 10250
  to_port                  = 10259
  protocol                 = "tcp"
  security_group_id        = aws_security_group.okd_master_sg.id
  source_security_group_id = aws_security_group.okd_worker_sg.id
}

resource "aws_security_group_rule" "MasterIngressIngressServices" {
  type                     = "ingress"
  description              = "Kubernetes ingress services"
  from_port                = 30000
  to_port                  = 32767
  protocol                 = "tcp"
  security_group_id        = aws_security_group.okd_master_sg.id
  source_security_group_id = aws_security_group.okd_master_sg.id
}

resource "aws_security_group_rule" "MasterIngressWorkerIngressServices" {
  type                     = "ingress"
  description              = "Kubernetes ingress services"
  from_port                = 30000
  to_port                  = 32767
  protocol                 = "tcp"
  security_group_id        = aws_security_group.okd_master_sg.id
  source_security_group_id = aws_security_group.okd_worker_sg.id
}

resource "aws_security_group_rule" "MasterIngressIngressServicesUDP" {
  type                     = "ingress"
  description              = "Kubernetes ingress services"
  from_port                = 30000
  to_port                  = 32767
  protocol                 = "udp"
  security_group_id        = aws_security_group.okd_master_sg.id
  source_security_group_id = aws_security_group.okd_master_sg.id
}

resource "aws_security_group_rule" "MasterIngressWorkerIngressServicesUDP" {
  type                     = "ingress"
  description              = "Kubernetes ingress services"
  from_port                = 30000
  to_port                  = 32767
  protocol                 = "udp"
  security_group_id        = aws_security_group.okd_master_sg.id
  source_security_group_id = aws_security_group.okd_worker_sg.id
}

resource "aws_security_group_rule" "WorkerIngressVxlan" {
  type                     = "ingress"
  description              = "Vxlan"
  from_port                = 4789
  to_port                  = 4789
  protocol                 = "udp"
  security_group_id        = aws_security_group.okd_worker_sg.id
  source_security_group_id = aws_security_group.okd_worker_sg.id
}

resource "aws_security_group_rule" "WorkerIngressMasterVxlan" {
  type                     = "ingress"
  description              = "Vxlan"
  from_port                = 4789
  to_port                  = 4789
  protocol                 = "udp"
  security_group_id        = aws_security_group.okd_worker_sg.id
  source_security_group_id = aws_security_group.okd_master_sg.id
}

resource "aws_security_group_rule" "WorkerIngressGeneve" {
  type                     = "ingress"
  description              = "Geneve"
  from_port                = 6081
  to_port                  = 6081
  protocol                 = "udp"
  security_group_id        = aws_security_group.okd_worker_sg.id
  source_security_group_id = aws_security_group.okd_worker_sg.id
}

resource "aws_security_group_rule" "WorkerIngressMasterGeneve" {
  type                     = "ingress"
  description              = "Geneve"
  from_port                = 6081
  to_port                  = 6081
  protocol                 = "udp"
  security_group_id        = aws_security_group.okd_worker_sg.id
  source_security_group_id = aws_security_group.okd_master_sg.id
}

resource "aws_security_group_rule" "WorkerIngressIpsecIke" {
  type                     = "ingress"
  description              = "IPsec IKE"
  from_port                = 500
  to_port                  = 500
  protocol                 = "udp"
  security_group_id        = aws_security_group.okd_worker_sg.id
  source_security_group_id = aws_security_group.okd_worker_sg.id
}

resource "aws_security_group_rule" "WorkerIngressIpsecNat" {
  type                     = "ingress"
  description              = "IPsec NAT-T"
  from_port                = 4500
  to_port                  = 4500
  protocol                 = "udp"
  security_group_id        = aws_security_group.okd_worker_sg.id
  source_security_group_id = aws_security_group.okd_worker_sg.id
}

resource "aws_security_group_rule" "WorkerIngressIpsecEsp" {
  type                     = "ingress"
  description              = "IPsec ESP"
  from_port                = 0
  to_port                  = 0
  protocol                 = 50
  security_group_id        = aws_security_group.okd_worker_sg.id
  source_security_group_id = aws_security_group.okd_worker_sg.id
}

resource "aws_security_group_rule" "WorkerIngressMasterIpsecIke" {
  type                     = "ingress"
  description              = "IPsec IKE"
  from_port                = 500
  to_port                  = 500
  protocol                 = "udp"
  security_group_id        = aws_security_group.okd_worker_sg.id
  source_security_group_id = aws_security_group.okd_master_sg.id
}

resource "aws_security_group_rule" "WorkerIngressMasterIpsecNat" {
  type                     = "ingress"
  description              = "IPsec NAT-T"
  from_port                = 4500
  to_port                  = 4500
  protocol                 = "udp"
  security_group_id        = aws_security_group.okd_worker_sg.id
  source_security_group_id = aws_security_group.okd_master_sg.id
}

resource "aws_security_group_rule" "WorkerIngressMasterIpsecEsp" {
  type                     = "ingress"
  description              = "IPsec ESP"
  from_port                = 0
  to_port                  = 0
  protocol                 = 50
  security_group_id        = aws_security_group.okd_worker_sg.id
  source_security_group_id = aws_security_group.okd_master_sg.id
}

resource "aws_security_group_rule" "WorkerIngressInternal" {
  type                     = "ingress"
  description              = "Internal cluster communication"
  from_port                = 9000
  to_port                  = 9900
  protocol                 = "tcp"
  security_group_id        = aws_security_group.okd_worker_sg.id
  source_security_group_id = aws_security_group.okd_worker_sg.id
}

resource "aws_security_group_rule" "WorkerIngressMasterInternal" {
  type                     = "ingress"
  description              = "Internal cluster communication"
  from_port                = 9000
  to_port                  = 9900
  protocol                 = "tcp"
  security_group_id        = aws_security_group.okd_worker_sg.id
  source_security_group_id = aws_security_group.okd_master_sg.id
}

resource "aws_security_group_rule" "WorkerIngressInternalUDP" {
  type                     = "ingress"
  description              = "Internal cluster communication"
  from_port                = 9000
  to_port                  = 9900
  protocol                 = "udp"
  security_group_id        = aws_security_group.okd_worker_sg.id
  source_security_group_id = aws_security_group.okd_worker_sg.id
}

resource "aws_security_group_rule" "WorkerIngressMasterInternalUDP" {
  type                     = "ingress"
  description              = "Internal cluster communication"
  from_port                = 9000
  to_port                  = 9900
  protocol                 = "udp"
  security_group_id        = aws_security_group.okd_worker_sg.id
  source_security_group_id = aws_security_group.okd_master_sg.id
}

resource "aws_security_group_rule" "WorkerIngressKube" {
  type                     = "ingress"
  description              = "Kubernetes secure kubelet port"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  security_group_id        = aws_security_group.okd_worker_sg.id
  source_security_group_id = aws_security_group.okd_worker_sg.id
}

resource "aws_security_group_rule" "WorkerIngressMasterKube" {
  type                     = "ingress"
  description              = "Internal Kubernetes communication"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  security_group_id        = aws_security_group.okd_worker_sg.id
  source_security_group_id = aws_security_group.okd_master_sg.id
}

resource "aws_security_group_rule" "WorkerIngressIngressServices" {
  type                     = "ingress"
  description              = "Kubernetes ingress services"
  from_port                = 30000
  to_port                  = 32767
  protocol                 = "tcp"
  security_group_id        = aws_security_group.okd_worker_sg.id
  source_security_group_id = aws_security_group.okd_worker_sg.id
}

resource "aws_security_group_rule" "WorkerIngressMasterIngressServices" {
  type                     = "ingress"
  description              = "Kubernetes ingress services"
  from_port                = 30000
  to_port                  = 32767
  protocol                 = "tcp"
  security_group_id        = aws_security_group.okd_worker_sg.id
  source_security_group_id = aws_security_group.okd_master_sg.id
}

resource "aws_security_group_rule" "WorkerIngressIngressServicesUDP" {
  type                     = "ingress"
  description              = "Kubernetes ingress services"
  from_port                = 30000
  to_port                  = 32767
  protocol                 = "udp"
  security_group_id        = aws_security_group.okd_worker_sg.id
  source_security_group_id = aws_security_group.okd_worker_sg.id
}

resource "aws_security_group_rule" "WorkerIngressMasterIngressServicesUDP" {
  type                     = "ingress"
  description              = "Kubernetes ingress services"
  from_port                = 30000
  to_port                  = 32767
  protocol                 = "udp"
  security_group_id        = aws_security_group.okd_worker_sg.id
  source_security_group_id = aws_security_group.okd_master_sg.id
}

# S3

resource "aws_s3_bucket" "okd-infra" {
  bucket        = "${var.okd_name}-infra"
  acl           = "private"
  force_destroy = true

  tags = {
    Name = "${var.okd_name}-infra"
    Lab  = "okd4"
  }
}

resource "aws_s3_bucket_object" "copy-bootstrap" {
  bucket       = aws_s3_bucket.okd-infra.id
  key          = "bootstrap.ign"
  source       = "${path.root}/install/bootstrap.ign"
  content_type = "binary/octet-stream"
  acl          = "public-read"
}

# IAM

data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "bootstrap-iam-role" {
  name = "${var.okd_name}-bootstrap-iam-role"
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
  path = "/"

  inline_policy {
    name = "${var.okd_name}-bootstrap-policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["ec2:Describe*"]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action   = ["ec2:AttachVolume"]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action   = ["ec2:DetachVolume"]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }
}

resource "aws_iam_instance_profile" "bootstrap_profile" {
  name = "${var.okd_name}-bootstrap-iam-profile"
  role = aws_iam_role.bootstrap-iam-role.name
}

# EC2

locals {
  bootstrap-ign = jsonencode({
    "ignition":{"config":{"replace":{"source":"https://${var.okd_name}-infra.s3-${var.aws_region}.amazonaws.com/bootstrap.ign"}},"version":"3.2.0"}
  })
}

resource "aws_instance" "okd-bootstrap" {
  ami                    = data.aws_ami.fcos_ami.id
  instance_type          = "m5.large"
  count                  = 1
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.okd_master_sg.id, aws_security_group.okd_bootstrap_sg.id]
  subnet_id              = var.vpc_subnet[0]
  #iam_instance_profile   = aws_iam_instance_profile.bootstrap_profile.name
  user_data              = local.bootstrap-ign

  root_block_device {
    volume_size           = 100
    delete_on_termination = true
  }

  depends_on = [
    aws_s3_bucket_object.copy-bootstrap
  ]

  tags = {
    Name = "${var.okd_name}-bootstrap"
    Lab  = "Containers"
  }
}

resource "aws_lb_target_group_attachment" "bootstrap-ext-6443" {
  count            = length(aws_instance.okd-bootstrap)
  target_group_arn = var.ext_tg_6443
  target_id        = aws_instance.okd-bootstrap[count.index].private_ip
  port             = 6443
}

resource "aws_lb_target_group_attachment" "bootstrap-int-6443" {
  count            = length(aws_instance.okd-bootstrap)
  target_group_arn = var.int_tg_6443
  target_id        = aws_instance.okd-bootstrap[count.index].private_ip
  port             = 6443
}

resource "aws_lb_target_group_attachment" "bootstrap-int-22623" {
  count            = length(aws_instance.okd-bootstrap)
  target_group_arn = var.int_tg_22623
  target_id        = aws_instance.okd-bootstrap[count.index].private_ip
  port             = 22623
}

locals {
  master-ign = jsonencode({
    "ignition":{"config":{"merge":[{"source":"${var.okd_masterignloc}"}]},"security":{"tls":{"certificateAuthorities":[{"source":"${var.okd_masterigncert}"}]}},"version":"3.2.0"}
  })
}

resource "aws_instance" "okd-master" {
  ami                    = data.aws_ami.fcos_ami.id
  instance_type          = "m5.xlarge"
  count                  = 3
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.okd_master_sg.id]
  subnet_id              = var.vpc_subnet[0]
  #private_ip             = "${lookup(var.okd_ips,count.index + 1)}"
  user_data              = local.master-ign

  root_block_device {
    volume_size           = 100
    delete_on_termination = true
  }

  tags = {
    Name = "okd-master-${count.index + 1}"
    Lab  = "Containers"
  }
}

locals {
  worker-ign = jsonencode({
    "ignition":{"config":{"merge":[{"source":"${var.okd_workerignloc}"}]},"security":{"tls":{"certificateAuthorities":[{"source":"${var.okd_workerigncert}"}]}},"version":"3.2.0"}
  })
}

#resource "aws_instance" "okd-worker" {
#  ami                    = data.aws_ami.fcos_ami.id
#  instance_type          = "m5.2xlarge"
#  count                  = 2
#  key_name               = var.key_name
#  vpc_security_group_ids = [aws_security_group.okd_worker_sg.id]
#  subnet_id              = var.vpc_subnet[0]
#  #private_ip             = "${lookup(var.okd_ips,count.index + 4)}"
#  user_data              = local.worker-ign

#  root_block_device {
#    volume_size           = 100
#    delete_on_termination = true
#  }

#  tags = {
#    Name = "okd-worker-${count.index + 1}"
#    Lab  = "Containers"
#  }
#}

#-------- okd output --------

#output "master-public_ip" {
#  value = formatlist(
#  "%s = %s",
#  aws_instance.okd-master.*.tags.Name,
#  aws_instance.okd-master.*.public_ip
#  )
#}

#output "worker-public_ip" {
#  value = formatlist(
#  "%s = %s",
#  aws_instance.okd-worker.*.tags.Name,
#  aws_instance.okd-worker.*.public_ip
#  )
#}

