resource "outscale_security_group" "sg" {
  description = "Syslog security group"
  net_id      = "vpc-df549e2d"
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
    from_port_range = "8200"
    to_port_range   = "8200"
    ip_protocol     = "tcp"
    ip_ranges       = var.allowed_cidr
  }
}

module "vm" {
  source             = "github.com/chimere-eu/ztiac/modules/outscale/compute"
  subnet_id          = "subnet-663cb334"
  security_group_ids = [outscale_security_group.sg.security_group_id]
  vm_type            = var.vm_type
  image_id           = var.image_id
  private_ip         = var.syslog_server_private_ip
  keypair_name       = outscale_keypair.my_keypair.keypair_name
  name               = "syslog-server"
  assign_public_ip   = true
  user_data          = file("syslog-server.sh")
  user_data_type     = "shell"
  block_device_mappings = [
    {
      device_name = "/dev/sda1"
      bsu = {
        volume_size           = 20
        volume_type           = "gp2"
        delete_on_vm_deletion = true
      }
    }
  ]
}

module "vm2" {
  source             = "github.com/chimere-eu/ztiac/modules/outscale/compute"
  subnet_id          = "subnet-663cb334"
  security_group_ids = [outscale_security_group.sg.security_group_id]
  vm_type            = var.vm_type
  image_id           = var.image_id
  private_ip         = "10.1.0.6"
  keypair_name       = outscale_keypair.my_keypair.keypair_name
  name               = "syslog-client"
  assign_public_ip   = true
  user_data          = local.client
  user_data_type     = "shell"
  block_device_mappings = [
    {
      device_name = "/dev/sda1"
      bsu = {
        volume_size           = 20
        volume_type           = "gp2"
        delete_on_vm_deletion = true
      }
    }
  ]
}



resource "outscale_keypair" "my_keypair" {
  keypair_name = "syslog-keypair"
  public_key   = file(var.public_key_path)
}

output "public_ips" {
  value = [module.vm.public_ip, module.vm2.public_ip]
}

locals {
  client = templatefile("./syslog-client.sh",
    {
      SYSLOG_SERVER_IP = var.syslog_server_private_ip
  })
}