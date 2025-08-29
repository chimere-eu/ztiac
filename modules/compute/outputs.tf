output "instance_id" {
  value = outscale_vm.this.vm_id
  description = "ID of the VM"
}

output "public_ip" {
  value = var.assign_public_ip ? outscale_public_ip.this[0].public_ip: null
  description = "Public IP of the VM"
}

output "private_ip" {
  value = outscale_vm.this.private_ip
  description = "Private IP of the VM"
}

output "user_data" {
  value = base64decode(data.cloudinit_config.user_data.rendered)
}