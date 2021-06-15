# okd-aws-lab

Testing ability to create an user provisioned OKD v4 deployment with Terraform.

Required (assuming linux cli)
  1. Configure aws credentials "default" profile (~/.aws/credentials)
  2. Clone this repo
  3. Download latest "client & "install" from github https://github.com/openshift/okd/releases
  4. Untar both files in root of clone
  5. Copy "oc" & "kubectl" to "/usr/local/bin"
  6. Run "./setup_ignition.sh"
  7. Run "terraform init"
  8. Run "terraform apply -auto-approve"
  9. export KUBECONFIG=/<path-to-clone>/install/auth/kubeconfig
  10. Monitor process (Time ~15m)
      - oc get nodes
      - oc get csr
  11. Once worker nodes are up you'll need to approve the csr. (TWICE)
      - oc get csr -o go-template='{{range .items}}{{if not .status}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}' | xargs --no-run-if-empty oc adm certificate approve
  12. Watch for cluster operators to deploy (Time ~30m)
      - oc get co
  