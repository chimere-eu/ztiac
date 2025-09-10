output "bastion_ip" {
  value       = module.bastion.public_ip
  description = "Public IP of the Bastion"
}
