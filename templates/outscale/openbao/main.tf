module "net" {
  source                     = "github.com/chimere-eu/ztiac/modules/outscale/vpc"
  availability_zones         = ["cloudgouv-eu-west-1a", "cloudgouv-eu-west-1b", "cloudgouv-eu-west-1c"]
  region                     = var.region
  net_cidr                   = "10.1.0.0/16"
  public_subnets             = ["10.1.0.0/24", "10.1.1.0/24"]
  private_subnets            = ["10.1.2.0/24", "10.1.3.0/24"]
  shared_private_route_table = false
  shared_public_route_table  = false
  enable_nat_gateway         = true
  shared_nat                 = true
  name                       = "openbao"
}



resource "outscale_keypair" "my_keypair" {
  keypair_name = "openbao-example-keypair"
  public_key   = file(var.public_key_path)
}


resource "outscale_security_group" "openbao_sg" {
  description = "Openbao security group"
  net_id      = module.net.vpc_id
}

resource "outscale_security_group_rule" "openbao_sg_rule_ssh" {
  flow              = "Inbound"
  security_group_id = outscale_security_group.openbao_sg.id
  rules {
    from_port_range = "22"
    to_port_range   = "22"
    ip_protocol     = "tcp"
    ip_ranges       = var.allowed_cidr
  }
}

resource "outscale_security_group_rule" "openbao_sg_rule" {
  flow              = "Inbound"
  security_group_id = outscale_security_group.openbao_sg.id
  rules {
    from_port_range = "8200"
    to_port_range   = "8200"
    ip_protocol     = "tcp"
    ip_ranges       = var.allowed_cidr
  }
}

module "vm" {
  source             = "github.com/chimere-eu/ztiac/modules/outscale/compute"
  subnet_id          = module.net.public_subnets["public-0"].id
  security_group_ids = [outscale_security_group.openbao_sg.security_group_id]
  vm_type            = var.vm_type
  image_id           = var.image_id
  private_ip         = "10.1.0.5"
  keypair_name       = outscale_keypair.my_keypair.keypair_name
  name               = "openbao"
  assign_public_ip   = true
  user_data          = file("config.yaml")
  user_data_type     = "cloud-config"
  block_device_mappings = [
    {
      device_name = "/dev/sda1"
      bsu = {
        volume_size           = 10
        volume_type           = "gp2"
        delete_on_vm_deletion = true
      }
    },
    {
      device_name = "/dev/sdb"
      bsu = {
        volume_size           = 15
        volume_type           = "gp2"
        delete_on_vm_deletion = true
      }
    }

  ]
}
