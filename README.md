# Create OKD v4 (UPI) deployment with Terraform.

The whole process will take ~30m.
I'm assuming Linux client (Required: awscli, jq, terraform)

  1. Configure your aws credentials using "default" profile (~/.aws/credentials)
  2. Clone this repo
  3. Download latest okd "client & "install" from github https://github.com/openshift/okd/releases
  4. Untar both files in root of clone
  5. Copy "oc" & "kubectl" to "/usr/local/bin"
  6. Run "./scripts/okd_deploy.sh
  7. Run "terraform init"
  8. Run "terraform apply -auto-approve"
  9. export KUBECONFIG=$PWD/ignition/auth/kubeconfig
  10. Monitor process for control nodes to go active. (Time ~15m)
      - oc get nodes
      - oc get csr
  11. Once worker nodes are up you'll need to approve their csr. Wait to see
      "Pending" and run the following command. This will need to be done twice.
      - oc get csr -o go-template='{{range .items}}{{if not .status}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}' | xargs --no-run-if-empty oc adm certificate approve
  12. Watch for cluster operators to deploy (Time ~30m)
      - watch -n3 oc get co
  