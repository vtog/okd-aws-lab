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
  type              = "ingress"
  description       = "etcd"
  from_port         = 2379
  to_port           = 2380
  protocol          = "tcp"
  security_group_id = aws_security_group.okd_master_sg.id
  source_security_group_id = aws_security_group.okd_master_sg.id
}

resource "aws_security_group_rule" "MasterIngressVxlan" {
  type              = "ingress"
  description       = "vxlan"
  from_port         = 4789
  to_port           = 4789
  protocol          = "udp"
  security_group_id = aws_security_group.okd_master_sg.id
  source_security_group_id = aws_security_group.okd_master_sg.id
}

resource "aws_security_group_rule" "MasterIngressWorkerVxlan" {
  type              = "ingress"
  description       = "vxlan"
  from_port         = 4789
  to_port           = 4789
  protocol          = "udp"
  security_group_id = aws_security_group.okd_master_sg.id
  source_security_group_id = aws_security_group.okd_worker_sg.id
}

resource "aws_security_group_rule" "MasterIngressGeneve" {
  type              = "ingress"
  description       = "geneve"
  from_port         = 6081
  to_port           = 6081
  protocol          = "udp"
  security_group_id = aws_security_group.okd_master_sg.id
  source_security_group_id = aws_security_group.okd_master_sg.id
}

resource "aws_security_group_rule" "MasterIngressWorkerGeneve" {
  type              = "ingress"
  description       = "geneve"
  from_port         = 6081
  to_port           = 6081
  protocol          = "udp"
  security_group_id = aws_security_group.okd_master_sg.id
  source_security_group_id = aws_security_group.okd_worker_sg.id
}

resource "aws_security_group_rule" "MasterIngressIpsecIke" {
  type              = "ingress"
  description       = "IPsec IKE"
  from_port         = 500
  to_port           = 500
  protocol          = "udp"
  security_group_id = aws_security_group.okd_master_sg.id
  source_security_group_id = aws_security_group.okd_master_sg.id
}

resource "aws_security_group_rule" "MasterIngressIpsecNat" {
  type              = "ingress"
  description       = "IPsec NAT-T"
  from_port         = 4500
  to_port           = 4500
  protocol          = "udp"
  security_group_id = aws_security_group.okd_master_sg.id
  source_security_group_id = aws_security_group.okd_master_sg.id
}

resource "aws_security_group_rule" "MasterIngressIpsecEsp" {
  type              = "ingress"
  description       = "IPsec ESP"
  from_port         = 0
  to_port           = 0
  protocol          = 50
  security_group_id = aws_security_group.okd_master_sg.id
  source_security_group_id = aws_security_group.okd_master_sg.id
}

resource "aws_security_group_rule" "MasterIngressWorkerIpsecIke" {
  type              = "ingress"
  description       = "IPsec IKE"
  from_port         = 500
  to_port           = 500
  protocol          = "udp"
  security_group_id = aws_security_group.okd_master_sg.id
  source_security_group_id = aws_security_group.okd_worker_sg.id
}

resource "aws_security_group_rule" "MasterIngressWorkerIpsecNat" {
  type              = "ingress"
  description       = "IPsec NAT-T"
  from_port         = 4500
  to_port           = 4500
  protocol          = "udp"
  security_group_id = aws_security_group.okd_master_sg.id
  source_security_group_id = aws_security_group.okd_worker_sg.id
}

resource "aws_security_group_rule" "MasterIngressWorkerIpsecEsp" {
  type              = "ingress"
  description       = "IPsec ESP"
  from_port         = 0
  to_port           = 0
  protocol          = 50
  security_group_id = aws_security_group.okd_master_sg.id
  source_security_group_id = aws_security_group.okd_worker_sg.id
}

resource "aws_security_group_rule" "MasterIngressInternal" {
  type              = "ingress"
  description       = "Internal cluster communication"
  from_port         = 9000
  to_port           = 9999
  protocol          = "tcp"
  security_group_id = aws_security_group.okd_master_sg.id
  source_security_group_id = aws_security_group.okd_master_sg.id
}

resource "aws_security_group_rule" "MasterIngressWorkerInternal" {
  type              = "ingress"
  description       = "Internal cluster communication"
  from_port         = 9000
  to_port           = 9999
  protocol          = "tcp"
  security_group_id = aws_security_group.okd_master_sg.id
  source_security_group_id = aws_security_group.okd_worker_sg.id
}

resource "aws_security_group_rule" "MasterIngressInternalUDP" {
  type              = "ingress"
  description       = "Interncal cluster communication"
  from_port         = 9000
  to_port           = 9999
  protocol          = "udp"
  security_group_id = aws_security_group.okd_master_sg.id
  source_security_group_id = aws_security_group.okd_master_sg.id
}

resource "aws_security_group_rule" "MasterIngressWorkerInternalUDP" {
  type              = "ingress"
  description       = "Internal cluster communication"
  from_port         = 9000
  to_port           = 9999
  protocol          = "udp"
  security_group_id = aws_security_group.okd_master_sg.id
  source_security_group_id = aws_security_group.okd_worker_sg.id
}

resource "aws_security_group_rule" "MasterIngressKube" {
  type              = "ingress"
  description       = "Kubernetes kubelet, scheduler and controller manager"
  from_port         = 10250
  to_port           = 10259
  protocol          = "tcp"
  security_group_id = aws_security_group.okd_master_sg.id
  source_security_group_id = aws_security_group.okd_master_sg.id
}

resource "aws_security_group_rule" "MasterIngressWorkerKube" {
  type              = "ingress"
  description       = "Kubernetes kubelet, scheduler and controller manager"
  from_port         = 10250
  to_port           = 10259
  protocol          = "tcp"
  security_group_id = aws_security_group.okd_master_sg.id
  source_security_group_id = aws_security_group.okd_worker_sg.id
}

resource "aws_security_group_rule" "MasterIngressIngressServices" {
  type              = "ingress"
  description       = "Kubernetes ingress services"
  from_port         = 30000
  to_port           = 32767
  protocol          = "tcp"
  security_group_id = aws_security_group.okd_master_sg.id
  source_security_group_id = aws_security_group.okd_master_sg.id
}

resource "aws_security_group_rule" "MasterIngressWorkerIngressServices" {
  type              = "ingress"
  description       = "Kubernetes ingress services"
  from_port         = 30000
  to_port           = 32767
  protocol          = "tcp"
  security_group_id = aws_security_group.okd_master_sg.id
  source_security_group_id = aws_security_group.okd_worker_sg.id
}

resource "aws_security_group_rule" "MasterIngressIngressServicesUDP" {
  type              = "ingress"
  description       = "Kubernetes ingress services"
  from_port         = 30000
  to_port           = 32767
  protocol          = "udp"
  security_group_id = aws_security_group.okd_master_sg.id
  source_security_group_id = aws_security_group.okd_master_sg.id
}

resource "aws_security_group_rule" "MasterIngressWorkerIngressServicesUDP" {
  type              = "ingress"
  description       = "Kubernetes ingress services"
  from_port         = 30000
  to_port           = 32767
  protocol          = "udp"
  security_group_id = aws_security_group.okd_master_sg.id
  source_security_group_id = aws_security_group.okd_worker_sg.id
}

resource "aws_security_group_rule" "WorkerIngressVxlan" {
  type              = "ingress"
  description       = "Vxlan"
  from_port         = 4789
  to_port           = 4789
  protocol          = "udp"
  security_group_id = aws_security_group.okd_worker_sg.id
  source_security_group_id = aws_security_group.okd_worker_sg.id
}

resource "aws_security_group_rule" "WorkerIngressMasterVxlan" {
  type              = "ingress"
  description       = "Vxlan"
  from_port         = 4789
  to_port           = 4789
  protocol          = "udp"
  security_group_id = aws_security_group.okd_worker_sg.id
  source_security_group_id = aws_security_group.okd_master_sg.id
}

resource "aws_security_group_rule" "WorkerIngressGeneve" {
  type              = "ingress"
  description       = "Geneve"
  from_port         = 6081
  to_port           = 6081
  protocol          = "udp"
  security_group_id = aws_security_group.okd_worker_sg.id
  source_security_group_id = aws_security_group.okd_worker_sg.id
}

resource "aws_security_group_rule" "WorkerIngressMasterGeneve" {
  type              = "ingress"
  description       = "Geneve"
  from_port         = 6081
  to_port           = 6081
  protocol          = "udp"
  security_group_id = aws_security_group.okd_worker_sg.id
  source_security_group_id = aws_security_group.okd_master_sg.id
}

resource "aws_security_group_rule" "WorkerIngressIpsecIke" {
  type              = "ingress"
  description       = "IPsec IKE"
  from_port         = 500
  to_port           = 500
  protocol          = "udp"
  security_group_id = aws_security_group.okd_worker_sg.id
  source_security_group_id = aws_security_group.okd_worker_sg.id
}

resource "aws_security_group_rule" "WorkerIngressIpsecNat" {
  type              = "ingress"
  description       = "IPsec NAT-T"
  from_port         = 4500
  to_port           = 4500
  protocol          = "udp"
  security_group_id = aws_security_group.okd_worker_sg.id
  source_security_group_id = aws_security_group.okd_worker_sg.id
}

resource "aws_security_group_rule" "WorkerIngressIpsecEsp" {
  type              = "ingress"
  description       = "IPsec ESP"
  from_port         = 0
  to_port           = 0
  protocol          = 50
  security_group_id = aws_security_group.okd_worker_sg.id
  source_security_group_id = aws_security_group.okd_worker_sg.id
}

resource "aws_security_group_rule" "WorkerIngressMasterIpsecIke" {
  type              = "ingress"
  description       = "IPsec IKE"
  from_port         = 500
  to_port           = 500
  protocol          = "udp"
  security_group_id = aws_security_group.okd_worker_sg.id
  source_security_group_id = aws_security_group.okd_master_sg.id
}

resource "aws_security_group_rule" "WorkerIngressMasterIpsecNat" {
  type              = "ingress"
  description       = "IPsec NAT-T"
  from_port         = 4500
  to_port           = 4500
  protocol          = "udp"
  security_group_id = aws_security_group.okd_worker_sg.id
  source_security_group_id = aws_security_group.okd_master_sg.id
}

resource "aws_security_group_rule" "WorkerIngressMasterIpsecEsp" {
  type              = "ingress"
  description       = "IPsec ESP"
  from_port         = 0
  to_port           = 0
  protocol          = 50
  security_group_id = aws_security_group.okd_worker_sg.id
  source_security_group_id = aws_security_group.okd_master_sg.id
}

resource "aws_security_group_rule" "WorkerIngressInternal" {
  type              = "ingress"
  description       = "Internal cluster communication"
  from_port         = 9000
  to_port           = 9900
  protocol          = "tcp"
  security_group_id = aws_security_group.okd_worker_sg.id
  source_security_group_id = aws_security_group.okd_worker_sg.id
}

resource "aws_security_group_rule" "WorkerIngressMasterInternal" {
  type              = "ingress"
  description       = "Internal cluster communication"
  from_port         = 9000
  to_port           = 9900
  protocol          = "tcp"
  security_group_id = aws_security_group.okd_worker_sg.id
  source_security_group_id = aws_security_group.okd_master_sg.id
}

resource "aws_security_group_rule" "WorkerIngressInternalUDP" {
  type              = "ingress"
  description       = "Internal cluster communication"
  from_port         = 9000
  to_port           = 9900
  protocol          = "udp"
  security_group_id = aws_security_group.okd_worker_sg.id
  source_security_group_id = aws_security_group.okd_worker_sg.id
}

resource "aws_security_group_rule" "WorkerIngressMasterInternalUDP" {
  type              = "ingress"
  description       = "Internal cluster communication"
  from_port         = 9000
  to_port           = 9900
  protocol          = "udp"
  security_group_id = aws_security_group.okd_worker_sg.id
  source_security_group_id = aws_security_group.okd_master_sg.id
}

resource "aws_security_group_rule" "WorkerIngressKube" {
  type              = "ingress"
  description       = "Kubernetes secure kubelet port"
  from_port         = 10250
  to_port           = 10250
  protocol          = "tcp"
  security_group_id = aws_security_group.okd_worker_sg.id
  source_security_group_id = aws_security_group.okd_worker_sg.id
}

resource "aws_security_group_rule" "WorkerIngressMasterKube" {
  type              = "ingress"
  description       = "Internal Kubernetes communication"
  from_port         = 10250
  to_port           = 10250
  protocol          = "tcp"
  security_group_id = aws_security_group.okd_worker_sg.id
  source_security_group_id = aws_security_group.okd_master_sg.id
}

resource "aws_security_group_rule" "WorkerIngressIngressServices" {
  type              = "ingress"
  description       = "Kubernetes ingress services"
  from_port         = 30000
  to_port           = 32767
  protocol          = "tcp"
  security_group_id = aws_security_group.okd_worker_sg.id
  source_security_group_id = aws_security_group.okd_worker_sg.id
}

resource "aws_security_group_rule" "WorkerIngressMasterIngressServices" {
  type              = "ingress"
  description       = "Kubernetes ingress services"
  from_port         = 30000
  to_port           = 32767
  protocol          = "tcp"
  security_group_id = aws_security_group.okd_worker_sg.id
  source_security_group_id = aws_security_group.okd_master_sg.id
}

resource "aws_security_group_rule" "WorkerIngressIngressServicesUDP" {
  type              = "ingress"
  description       = "Kubernetes ingress services"
  from_port         = 30000
  to_port           = 32767
  protocol          = "udp"
  security_group_id = aws_security_group.okd_worker_sg.id
  source_security_group_id = aws_security_group.okd_worker_sg.id
}

resource "aws_security_group_rule" "WorkerIngressMasterIngressServicesUDP" {
  type              = "ingress"
  description       = "Kubernetes ingress services"
  from_port         = 30000
  to_port           = 32767
  protocol          = "udp"
  security_group_id = aws_security_group.okd_worker_sg.id
  source_security_group_id = aws_security_group.okd_master_sg.id
}

# S3

resource "aws_s3_bucket" "okd-infra" {
  bucket = "${var.okd_name}-infra"
  acl    = "private"
  force_destroy = true

  tags = {
    Name = "${var.okd_name}-infra"
    Lab  = "okd4"
  }
}

resource "aws_s3_bucket_object" "copy-bootstrap" {
  bucket = aws_s3_bucket.okd-infra.id
  key    = "bootstrap.ign"
  source = "${path.root}/install/bootstrap.ign"
}

data "aws_s3_bucket_object" "bootstrap" {
  bucket = "${var.okd_name}-infra"
  key    = "bootstrap.ign"
}


resource "aws_instance" "okd-bootstrap" {
  ami                    = data.aws_ami.fcos_ami.id
  instance_type          = "m5.large"
  count                  = 1
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.okd_master_sg.id, aws_security_group.okd_bootstrap_sg.id]
  subnet_id              = var.vpc_subnet[0]
  user_data              = data.aws_s3_bucket_object.bootstrap.body

  root_block_device {
    volume_size           = 100
    delete_on_termination = true
  }

  tags = {
    Name = "${var.okd_name}-bootstrap"
    Lab  = "Containers"
  }
}

#resource "aws_instance" "okd-master" {
#  ami                    = data.aws_ami.fcos_ami.id
#  instance_type          = "m5.xlarge"
#  count                  = 3
#  key_name               = var.key_name
#  vpc_security_group_ids = [aws_security_group.okd_sg.id]
#  subnet_id              = var.vpc_subnet[0]
#  private_ip             = "${lookup(var.okd_ips,count.index + 1)}"

#  root_block_device {
#    volume_size           = 100
#    delete_on_termination = true
#  }

#  tags = {
#    Name = "okd-master-${count.index + 1}"
#    Lab  = "Containers"
#  }
#}

#resource "aws_instance" "okd-worker" {
#  ami                    = data.aws_ami.fcos_ami.id
#  instance_type          = "m5.large"
#  count                  = 2
#  key_name               = var.key_name
#  vpc_security_group_ids = [aws_security_group.okd_sg.id]
#  subnet_id              = var.vpc_subnet[0]
#  private_ip             = "${lookup(var.okd_ips,count.index + 4)}"

#  root_block_device {
#    volume_size           = 100
#    delete_on_termination = true
#  }

#  tags = {
#    Name = "okd-worker-${count.index + 1}"
#    Lab  = "Containers"
#  }
#}

# write out centos inventory
#data "template_file" "inventory" {
#  template = <<EOF
#[all]
#%{ for instance in aws_instance.okd-bootstrap ~}
#${instance.tags.Name} ansible_host=${instance.public_ip} private_ip=${instance.private_ip}
#%{ endfor ~}
#%{ for instance in aws_instance.okd-master ~}
#${instance.tags.Name} ansible_host=${instance.public_ip} private_ip=${instance.private_ip}
#%{ endfor ~}
#%{ for instance in aws_instance.okd-worker ~}
#${instance.tags.Name} ansible_host=${instance.public_ip} private_ip=${instance.private_ip}
#%{ endfor ~}

#[masters]
#%{ for instance in aws_instance.okd-master ~}
#${instance.tags.Name} ansible_host=${instance.public_ip} private_ip=${instance.private_ip}
#%{ endfor ~}

#[nodes]
#%{ for instance in aws_instance.okd-worker ~}
#${instance.tags.Name} ansible_host=${instance.public_ip} private_ip=${instance.private_ip}
#%{ endfor ~}

#[all:vars]
#ansible_user=core
#ansible_playbook_python=/usr/bin/python3

#EOF
#}

#resource "local_file" "save_inventory" {
#  depends_on = [data.template_file.inventory]
#  content    = data.template_file.inventory.rendered
#  filename   = "./okd/ansible/inventory.ini"
#}

#----- Run Ansible Playbook -----
#resource "null_resource" "ansible" {
#  provisioner "local-exec" {
#    working_dir = "./okd/ansible/"
#
#    command = <<EOF
#    aws ec2 wait instance-status-ok --region ${var.aws_region} --profile ${var.aws_profile} --instance-ids ${join(" ", aws_instance.okd-master.*.id)}
#    ansible-playbook ./playbooks/prep-fcos.yaml
#    EOF
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

