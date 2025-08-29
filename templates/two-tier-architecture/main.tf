resource "outscale_keypair" "my_keypair" {
  keypair_name = "reverse-proxy-keypair"
  public_key   = file(var.public_key_path)
}

module "net" {
  source                     = "github.com/chimere-eu/ztiac/modules/vpc"
  availability_zones         = ["cloudgouv-eu-west-1a", "cloudgouv-eu-west-1b"]
  region                     = var.region
  net_cidr                   = "10.1.0.0/16"
  public_subnets             = ["10.1.0.0/24", "10.1.1.0/24"]
  private_subnets            = ["10.1.2.0/24", "10.1.3.0/24", "10.1.4.0/24", "10.1.5.0/24"]
  shared_private_route_table = false
  shared_public_route_table  = false
  enable_nat_gateway         = true
  shared_nat                 = false
  one_nat_gateway_per_az     = true
  name                       = "two-tier-example"
}

resource "outscale_security_group" "sg_bastion" {
  description         = "Two tier security group"
  net_id              = module.net.vpc_id
  security_group_name = "two-tier-example-bastion-sg"
}

resource "outscale_security_group_rule" "sg_rule_ssh" {
  flow              = "Inbound"
  security_group_id = outscale_security_group.sg_bastion.id
  rules {
    from_port_range = "22"
    to_port_range   = "22"
    ip_protocol     = "tcp"
    ip_ranges       = var.allowed_cidr
  }
}
resource "outscale_security_group" "sg_tier_1" {
  description         = "Tier 1 security group"
  net_id              = module.net.vpc_id
  security_group_name = "two-tier-example-tier-1-sg"

}


resource "outscale_security_group_rule" "sg_tier_1_rule" {
  flow              = "Inbound"
  security_group_id = outscale_security_group.sg_tier_1.id
  rules {
    from_port_range = "443"
    to_port_range   = "443"
    ip_protocol     = "tcp"
    security_groups_members {
      account_id        = outscale_security_group.sg_public_lb.account_id
      security_group_id = outscale_security_group.sg_public_lb.id
    }
  }
  rules {
    from_port_range = "80"
    to_port_range   = "80"
    ip_protocol     = "tcp"
    security_groups_members {
      account_id        = outscale_security_group.sg_public_lb.account_id
      security_group_id = outscale_security_group.sg_public_lb.id
    }
  }
  rules {
    from_port_range = "22"
    to_port_range   = "22"
    ip_protocol     = "tcp"
    security_groups_members {
      account_id        = outscale_security_group.sg_bastion.account_id
      security_group_id = outscale_security_group.sg_bastion.id
    }
  }
}

resource "outscale_security_group" "sg_tier_2" {
  description         = "Tier 2 security group"
  net_id              = module.net.vpc_id
  security_group_name = "two-tier-example-tier-2-sg"
}
resource "outscale_security_group_rule" "sg_tier_2_rule" {
  flow              = "Inbound"
  security_group_id = outscale_security_group.sg_tier_2.id
  rules {
    from_port_range = "80"
    to_port_range   = "80"
    ip_protocol     = "tcp"
    security_groups_members {
      account_id        = outscale_security_group.sg_internal_lb.account_id
      security_group_id = outscale_security_group.sg_internal_lb.id
    }
  }
  rules {
    from_port_range = "22"
    to_port_range   = "22"
    ip_protocol     = "tcp"
    security_groups_members {
      account_id        = outscale_security_group.sg_bastion.account_id
      security_group_id = outscale_security_group.sg_bastion.id
    }
  }
}

resource "outscale_security_group" "sg_public_lb" {
  description         = "Two tier security group public lb"
  net_id              = module.net.vpc_id
  security_group_name = "two-tier-example-tier-1-lb-sg"
}

resource "outscale_security_group_rule" "sg_rule_public_lb" {
  flow              = "Inbound"
  security_group_id = outscale_security_group.sg_public_lb.id
  rules {
    from_port_range = "80"
    to_port_range   = "80"
    ip_protocol     = "tcp"
    ip_ranges       = ["0.0.0.0/0"]
  }
  rules {
    from_port_range = "443"
    to_port_range   = "443"
    ip_protocol     = "tcp"
    ip_ranges       = ["0.0.0.0/0"]
  }
}


resource "outscale_security_group" "sg_internal_lb" {
  description         = "Two tier security group internal lb"
  net_id              = module.net.vpc_id
  security_group_name = "two-tier-example-tier-2-lb-sg"
}

resource "outscale_security_group_rule" "sg_rule_internal_lb" {
  flow              = "Inbound"
  security_group_id = outscale_security_group.sg_internal_lb.id
  rules {
    from_port_range = "80"
    to_port_range   = "80"
    ip_protocol     = "tcp"
    security_groups_members {
      account_id        = outscale_security_group.sg_internal_lb.account_id
      security_group_id = outscale_security_group.sg_tier_1.id
    }
  }
}

module "vm_bastion" {
  source             = "github.com/chimere-eu/ztiac/modules/compute"
  subnet_id          = module.net.public_subnets["public-0"].id
  security_group_ids = [outscale_security_group.sg_bastion.security_group_id]
  vm_type            = var.vm_type
  image_id           = var.image_id
  keypair_name       = outscale_keypair.my_keypair.keypair_name
  name               = "bastion-two-tier-example"
  assign_public_ip   = true
}

locals {
  caddyfile = templatefile("Caddyfile", {
    public_lb_dns_name  = outscale_load_balancer.public.dns_name
    private_lb_dns_name = outscale_load_balancer.internal.dns_name
  })
}

module "vm_tier_1" {
  count              = 2
  source             = "github.com/chimere-eu/ztiac/modules/compute"
  subnet_id          = module.net.private_subnets["private-${count.index}"].id
  security_group_ids = [outscale_security_group.sg_tier_1.security_group_id]
  vm_type            = var.vm_type
  image_id           = var.image_id
  keypair_name       = outscale_keypair.my_keypair.keypair_name
  name               = "tier-1"
  assign_public_ip   = false
  reverse_proxy = {
    caddyfile = local.caddyfile
  }
}



module "vm_tier_2" {
  count              = 2
  source             = "github.com/chimere-eu/ztiac/modules/compute"
  subnet_id          = module.net.private_subnets["private-${count.index + 2}"].id
  security_group_ids = [outscale_security_group.sg_tier_2.security_group_id]
  vm_type            = var.vm_type
  image_id           = var.image_id
  keypair_name       = outscale_keypair.my_keypair.keypair_name
  name               = "tier-2"
  assign_public_ip   = false
  user_data          = <<-EOF
  #!/bin/bash
  apt update
  apt install nginx -y
EOF
}

resource "outscale_load_balancer" "public" {
  load_balancer_name = "two-tier-public-lb"
  listeners {
    backend_port           = 80
    backend_protocol       = "TCP"
    load_balancer_protocol = "TCP"
    load_balancer_port     = 80
  }

  subnets            = [module.net.public_subnets["public-0"].id]
  security_groups    = [outscale_security_group.sg_public_lb.id]
  load_balancer_type = "internet-facing"
  tags {
    key   = "name"
    value = "two-tier-public-lb"
  }
}

resource "outscale_load_balancer_vms" "tier_1" {
  load_balancer_name = outscale_load_balancer.public.load_balancer_name
  backend_vm_ids     = [module.vm_tier_1[0].instance_id, module.vm_tier_1[1].instance_id]
}

resource "outscale_load_balancer" "internal" {
  load_balancer_name = "two-tier-internal-lb"
  listeners {
    backend_port           = 80
    backend_protocol       = "TCP"
    load_balancer_protocol = "TCP"
    load_balancer_port     = 80
  }
  subnets            = [module.net.private_subnets["private-2"].id]
  security_groups    = [outscale_security_group.sg_internal_lb.id]
  load_balancer_type = "internal"
  tags {
    key   = "name"
    value = "two-tier-internal-lb"
  }
}

resource "outscale_load_balancer_vms" "tier_2" {
  load_balancer_name = outscale_load_balancer.internal.load_balancer_name
  backend_vm_ids     = [module.vm_tier_2[0].instance_id, module.vm_tier_2[1].instance_id]
}


resource "outscale_load_balancer_attributes" "attributes_public" {
  load_balancer_name = outscale_load_balancer.public.id
  health_check {
    healthy_threshold   = 2
    check_interval      = 30
    port                = 80
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 5
  }
}