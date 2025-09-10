module "net1" {
  source                     = "github.com/chimere-eu/ztiac/modules/outscale/vpc"
  name                       = "network1"
  availability_zones         = ["cloudgouv-eu-west-1a", "cloudgouv-eu-west-1b", "cloudgouv-eu-west-1c"]
  region                     = var.region
  net_cidr                   = "10.1.0.0/16"
  public_subnets             = ["10.1.0.0/24", "10.1.1.0/24", "10.1.2.0/24"]
  private_subnets            = ["10.1.3.0/24", "10.1.4.0/24", "10.1.5.0/24"]
  shared_private_route_table = false
  shared_public_route_table  = false
  enable_nat_gateway         = true
  shared_nat                 = false
}

module "net2" {
  source                     = "github.com/chimere-eu/ztiac/modules/outscale/vpc"
  name                       = "network2"
  availability_zones         = ["cloudgouv-eu-west-1a", "cloudgouv-eu-west-1b", "cloudgouv-eu-west-1c"]
  region                     = var.region
  net_cidr                   = "10.2.0.0/16"
  public_subnets             = ["10.2.0.0/24", "10.2.1.0/24", "10.2.2.0/24"]
  private_subnets            = ["10.2.3.0/24", "10.2.4.0/24", "10.2.5.0/24"]
  shared_private_route_table = false
  shared_public_route_table  = false
  enable_nat_gateway         = true
  shared_nat                 = false
}


module "dmz" {
  source                    = "github.com/chimere-eu/ztiac/modules/outscale/vpc"
  name                      = "DMZ"
  availability_zones        = ["cloudgouv-eu-west-1a", "cloudgouv-eu-west-1b", "cloudgouv-eu-west-1c"]
  region                    = var.region
  net_cidr                  = "10.3.0.0/16"
  public_subnets            = ["10.3.0.0/24", "10.3.1.0/24", "10.3.2.0/24"]
  private_subnets           = []
  shared_public_route_table = false
  enable_nat_gateway        = false

}

resource "outscale_net_peering" "net_peering" {
  accepter_net_id = module.net1.vpc_id
  source_net_id   = module.net2.vpc_id
}

resource "outscale_net_peering_acceptation" "net_peering_acceptation" {
  net_peering_id = outscale_net_peering.net_peering.net_peering_id
}

resource "outscale_route" "peering_route1" {
  for_each             = merge(module.net1.public_rtb, module.net1.private_rtb)
  route_table_id       = each.value.id
  net_peering_id       = outscale_net_peering.net_peering.id
  destination_ip_range = module.net2.vpc_cidr
}

resource "outscale_route" "peering_route2" {
  for_each             = merge(module.net2.public_rtb, module.net2.private_rtb)
  route_table_id       = each.value.id
  net_peering_id       = outscale_net_peering.net_peering.id
  destination_ip_range = module.net1.vpc_cidr
}
