output "vm" {
  value       = module.vm.public_ip
  description = "Public IP of the first VM"
}

output "vm2" {
  value       = module.reverse_proxy2.public_ip
  description = "Public IP of the second VM"
}
