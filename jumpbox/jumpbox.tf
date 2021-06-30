data "aws_ami" "ubuntu_ami" {
  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-*-amd64*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "jumpbox_mgmt_sg" {
  name   = "jumpbox_mgmt_sg"
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
    Name = "jumpbox_mgmt_sg"
    Lab  = "okd4"
  }
}

resource "aws_instance" "jumpbox" {
  ami                    = data.aws_ami.ubuntu_ami.id
  instance_type          = "m5.large"
  count                  = 1
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.jumpbox_mgmt_sg.id]
  subnet_id              = var.vpc_subnet[0]

  root_block_device {
    volume_size           = 100
    delete_on_termination = true
  }

  tags = {
    Name = "okd4-jumpbox"
    Lab  = "okd4"
  }
}

# write out services inventory
data "template_file" "inventory" {
  template = <<EOF
[all]
%{ for instance in aws_instance.jumpbox ~}
${instance.tags.Name} ansible_host=${instance.public_ip} private_ip=${instance.private_ip}
%{ endfor ~}

[all:vars]
ansible_user=ubuntu
ansible_python_interpreter=/usr/bin/python3
EOF

}

resource "local_file" "save_inventory" {
  depends_on = [data.template_file.inventory]
  content = data.template_file.inventory.rendered
  filename = "./jumpbox/ansible/inventory.ini"
}

#----- Run Ansible Playbook -----
resource "null_resource" "ansible" {
  provisioner "local-exec" {
    working_dir = "./jumpbox/ansible/"

    command = <<EOF
    aws ec2 wait instance-status-ok --region ${var.aws_region} --profile ${var.aws_profile} --instance-ids ${join(" ", aws_instance.jumpbox.*.id)}
    ansible-playbook ./playbooks/deploy-services.yaml
    EOF
  }
}

#-------- services output --------

#output "public_ip" {
  #value = formatlist(
  #"%s = %s",
  #aws_instance.jumpbox.*.tags.Name,
  #aws_instance.jumpbox.*.public_ip
  #)
#}

