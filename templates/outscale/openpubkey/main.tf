resource "outscale_security_group" "sg" {
  description = "Opk demo security group"
  net_id      = "vpc-a1f7ba88"
}

resource "outscale_security_group_rule" "sg_rule_ssh" {
  flow              = "Inbound"
  security_group_id = outscale_security_group.sg.id
  rules {
    from_port_range = "22"
    to_port_range   = "22"
    ip_protocol     = "tcp"
    ip_ranges       = var.allowed_cidr
  }
}

resource "outscale_keypair" "my_keypair" {
  keypair_name = "openpubkey-example-keypair"
  public_key   = file(var.public_key_path)
}


module "vm" {
  source = "github.com/chimere-eu/ztiac/modules/outscale/compute"
  subnet_id          = "subnet-a15ae162"
  security_group_ids = [outscale_security_group.sg.security_group_id]
  vm_type            = var.vm_type
  image_id           = var.image_id
  private_ip         = "10.1.0.10"
  keypair_name       = outscale_keypair.my_keypair.keypair_name
  name               = "opk-demo"
  assign_public_ip   = true
  key_file           = "./ssh_keys"
  user_data          = file("config.yaml.tpl")
  user_data_type     = "cloud-config"
  openpubkey = {
    enable           = true
    use_auth_id_file = true
  }
}

output "vm" {
  value = module.vm.public_ip
}
