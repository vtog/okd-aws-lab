# Create OKD v4 (UPI) deployment with Terraform.

The whole process will take ~30m.
I'm assuming Linux client (Required: awscli, jq, terraform)

  1. Configure your aws credentials using "default" profile (~/.aws/credentials)
  2. I'm assuming you already have an SSH key generated in the default ~/.ssh directory.
     - If not use the following, "ssh-keygen -t rsa -b 4096" or however you'd like to generate the keys.
  3. Clone this repo
  4. Be sure to adjust the domains in the following files for your environment.
     - "public_domain" in ./terraform.tfvars
     - "baseDomain" in ./okd/ignition/install-config.yaml
  6. Download latest okd "client & "install" from github https://github.com/openshift/okd/releases
     - For corp account use "4.7.0-0.okd-2021-05-22-050008", newer version don't like session tokens.
  7. Untar both files in root of clone repo
  8. Move "oc" & "kubectl" to "/usr/local/bin"
  9.  Run "./scripts/okd_deploy.sh"
  10. Run "terraform init"
  11. Run "terraform apply -auto-approve"
  12. "export KUBECONFIG=$PWD/ignition/auth/kubeconfig"
  13. Monitor process for control nodes to go active. (Time ~15m)
      - oc get nodes
      - oc get csr
  14. Once worker nodes are up you'll need to approve their csr. Wait to see
      "Pending" and run the following command. This will need to be done twice.
      - oc get csr -o go-template='{{range .items}}{{if not .status}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}' | xargs --no-run-if-empty oc adm certificate approve
  15. Watch for cluster operators to deploy (Time ~30m)
      - watch -n3 oc get co
  