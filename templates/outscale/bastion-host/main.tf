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
  name                       = "bastion-example-network"
}

resource "outscale_security_group" "bastion_sg" {
  description = "Bastion example security group for bastion"
  net_id      = module.net.vpc_id
}

resource "outscale_security_group_rule" "bastion_sg_rule" {
  flow              = "Inbound"
  security_group_id = outscale_security_group.bastion_sg.id
  rules {
    from_port_range = "22"
    to_port_range   = "22"
    ip_protocol     = "tcp"
    ip_ranges       = var.allowed_cidr
  }
}


resource "outscale_security_group" "vm_sg" {
  description = "Bastion example security group for VM"
  net_id      = module.net.vpc_id
}

resource "outscale_security_group_rule" "vm_sg_rule" {
  flow              = "Inbound"
  security_group_id = outscale_security_group.vm_sg.id
  rules {
    from_port_range = "22"
    to_port_range   = "22"
    ip_protocol     = "tcp"
    ip_ranges       = ["${module.bastion.private_ip}/32"]
  }
}

module "bastion" {
  source             = "github.com/chimere-eu/ztiac/modules/outscale/compute"
  subnet_id          = module.net.public_subnets["public-0"].id
  security_group_ids = [outscale_security_group.bastion_sg.security_group_id]
  vm_type            = var.vm_type
  image_id           = var.image_id
  private_ip         = "10.1.0.5"
  keypair_name       = outscale_keypair.my_keypair.keypair_name
  name               = "bastion-example"
  assign_public_ip   = true
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


module "vm" {
  source             = "github.com/chimere-eu/ztiac/modules/outscale/compute"
  subnet_id          = module.net.private_subnets["private-0"].id
  security_group_ids = [outscale_security_group.vm_sg.security_group_id]
  private_ip         = "10.1.2.45"
  vm_type            = var.vm_type
  image_id           = var.image_id
  keypair_name       = outscale_keypair.my_keypair.keypair_name
  name               = "bastion-example-vm"
  assign_public_ip   = false
  user_data          = filebase64("script.sh")
}

resource "outscale_keypair" "my_keypair" {
  keypair_name = "bastion-example-keypair"
  public_key   = file(var.public_key_path)
}
