aws_profile = "default"
aws_region  = "us-west-2"

vpc_cidr = "10.0.0.0/16"

cidrs = {
  public1  = "10.0.0.0/20"
  private1 = "10.0.16.0/20"
}

key_name        = "container-lab-key"
public_key_path = "~/.ssh/id_rsa.pub"

master_inst_type = "m5.xlarge"
master_count     = 3
worker_inst_type = "m5.2xlarge"
worker_count     = 2

domain = "tognaci.com"

