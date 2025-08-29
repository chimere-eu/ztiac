resource "outscale_keypair" "my_keypair" {
  keypair_name = "reverse-proxy-keypair"
  public_key   = file(var.public_key_path)
}


resource "outscale_security_group" "sg" {
  description = "Reverse Proxy security group"
  net_id      = "vpc-9db188ae"
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

resource "outscale_security_group_rule" "sg_rule" {
  flow              = "Inbound"
  security_group_id = outscale_security_group.sg.id
  rules {
    from_port_range = "443"
    to_port_range   = "443"
    ip_protocol     = "tcp"
    ip_ranges       = var.allowed_cidr
  }
}
resource "outscale_security_group_rule" "sg_rule02" {
  flow              = "Inbound"
  security_group_id = outscale_security_group.sg.id
  rules {
    from_port_range = "80"
    to_port_range   = "80"
    ip_protocol     = "tcp"
    ip_ranges       = ["0.0.0.0/0"]
  }
}

module "vm" {
  source             = "github.com/chimere-eu/ztiac/modules/compute"
  subnet_id          = "subnet-3a1bff68"
  security_group_ids = [outscale_security_group.sg.security_group_id]
  vm_type            = var.vm_type
  image_id           = var.image_id
  keypair_name       = outscale_keypair.my_keypair.keypair_name
  name               = "reverse-proxy"
  assign_public_ip   = true
  reverse_proxy = {
    address  = "127.0.0.1"
    port     = 443
    upstream = "127.0.0.7:5000"
  }
}

output "vm" {
  value = module.vm.public_ip
}

module "reverse_proxy2" {
  source             = "github.com/chimere-eu/ztiac/modules/compute"
  subnet_id          = "subnet-3a1bff68"
  security_group_ids = [outscale_security_group.sg.security_group_id]
  vm_type            = var.vm_type
  image_id           = var.image_id
  keypair_name       = outscale_keypair.my_keypair.keypair_name
  name               = "reverse-proxy"
  assign_public_ip   = true
  reverse_proxy = {
    caddyfile = file("./Caddyfile")
  }
}

output "vm2" {
  value = module.reverse_proxy2.public_ip
}