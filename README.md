# okd-aws-lab

Testing ability to create an user provisioned OKD v4 deployment with Terraform.

Required (assuming linux cli)
  #. Configure aws credentials "default" profile (~/.aws/credentials)
  #. Clone this repo
  #. Download latest "client & "install" from github https://github.com/openshift/okd/releases
  #. Untar both files in root of clone
  #. Copy "oc" & "kubectl" to "/usr/local/bin"
  #. Run "./setup_ignition.sh"
  #. Run "terraform init"
  #. Run "terraform apply -auto-approve"
