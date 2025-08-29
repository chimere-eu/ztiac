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
  shared_nat                 = false
  name                       = "vpc-with-nat-example"
}
