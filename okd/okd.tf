data "aws_ami" "fcos_ami" {
  most_recent = true
  owners      = ["125523088429"]

  filter {
    name   = "name"
    values = ["fedora-coreos-34*"]
  }

  filter {
    name   = "description"
    values = ["Fedora CoreOS stable**"]
  }
}

resource "aws_security_group" "okd_sg" {
  name   = "okd_sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.myIP]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.myIP]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.myIP]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "okd_sg"
    Lab  = "Containers"
  }
}

resource "aws_instance" "okd-bootstrap" {
  ami                    = data.aws_ami.fcos_ami.id
  instance_type          = "m5.large"
  count                  = 1
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.okd_sg.id]
  subnet_id              = var.vpc_subnet[0]

  root_block_device {
    volume_size           = 100
    delete_on_termination = true
  }

  tags = {
    Name = "okd-bootstrap"
    Lab  = "Containers"
  }
}

resource "aws_instance" "okd-master" {
  ami                    = data.aws_ami.fcos_ami.id
  instance_type          = "m5.xlarge"
  count                  = var.okd_master_count
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.okd_sg.id]
  subnet_id              = var.vpc_subnet[0]

  root_block_device {
    volume_size           = 100
    delete_on_termination = true
  }

  tags = {
    Name = "okd-master-${count.index + 1}"
    Lab  = "Containers"
  }
}

resource "aws_instance" "okd-worker" {
  ami                    = data.aws_ami.fcos_ami.id
  instance_type          = "m5.large"
  count                  = var.okd_node_count
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.okd_sg.id]
  subnet_id              = var.vpc_subnet[0]

  root_block_device {
    volume_size           = 100
    delete_on_termination = true
  }

  tags = {
    Name = "okd-worker-${count.index + 1}"
    Lab  = "Containers"
  }
}

# write out centos inventory
data "template_file" "inventory" {
  template = <<EOF
[all]
%{ for instance in aws_instance.okd-bootstrap ~}
${instance.tags.Name} ansible_host=${instance.public_ip} private_ip=${instance.private_ip}
%{ endfor ~}
%{ for instance in aws_instance.okd-master ~}
${instance.tags.Name} ansible_host=${instance.public_ip} private_ip=${instance.private_ip}
%{ endfor ~}
%{ for instance in aws_instance.okd-worker ~}
${instance.tags.Name} ansible_host=${instance.public_ip} private_ip=${instance.private_ip}
%{ endfor ~}

[masters]
%{ for instance in aws_instance.okd-master ~}
${instance.tags.Name} ansible_host=${instance.public_ip} private_ip=${instance.private_ip}
%{ endfor ~}

[nodes]
%{ for instance in aws_instance.okd-worker ~}
${instance.tags.Name} ansible_host=${instance.public_ip} private_ip=${instance.private_ip}
%{ endfor ~}

[all:vars]
ansible_user=core
ansible_playbook_python=/usr/bin/python3

EOF
}

resource "local_file" "save_inventory" {
  depends_on = [data.template_file.inventory]
  content    = data.template_file.inventory.rendered
  filename   = "./okd/ansible/inventory.ini"
}

#----- Run Ansible Playbook -----
resource "null_resource" "ansible" {
  provisioner "local-exec" {
    working_dir = "./okd/ansible/"

    command = <<EOF
    aws ec2 wait instance-status-ok --region ${var.aws_region} --profile ${var.aws_profile} --instance-ids ${join(" ", aws_instance.okd-master.*.id)}
    ansible-playbook ./playbooks/prep-fcos.yaml
    EOF
  }
}

#-------- okd output --------

output "master-public_ip" {
  value = formatlist(
  "%s = %s",
  aws_instance.okd-master.*.tags.Name,
  aws_instance.okd-master.*.public_ip
  )
}

output "worker-public_ip" {
  value = formatlist(
  "%s = %s",
  aws_instance.okd-worker.*.tags.Name,
  aws_instance.okd-worker.*.public_ip
  )
}

