output "public_ips" {
  value       = [module.vm.public_ip, module.vm2.public_ip]
  description = "Public IPs of the VMs"
}
