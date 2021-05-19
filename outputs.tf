#--------root/outputs.tf--------
output "OKD_Cluster_IPs" {
  value = module.svc.public_ip
}
