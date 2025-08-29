resource "outscale_nat_service" "this" {
  count        = var.enable_nat_gateway ? local.nb_nat_gateway : 0
  subnet_id    = element(outscale_subnet.public, count.index).subnet_id
  public_ip_id = outscale_public_ip.this[count.index].public_ip_id
  depends_on   = [outscale_route.public]
  tags {
    key   = "name"
    value = "${var.name}-nat-${count.index}"
  }
}

locals {
  nb_nat_gateway = length(var.private_subnets) == 0 || var.enable_nat_gateway == false  ? 0 : ( var.shared_nat ? 1 : (  var.one_nat_gateway_per_az ? min(length(var.availability_zones),length(var.public_subnets)) : length(var.private_subnets)) )
}

check "nat_configuration" {
  assert {
    condition     = ( local.nb_nat_gateway <= local.len_public_subnets && var.enable_nat_gateway == true ) || var.enable_nat_gateway == false
    error_message = "ERROR: When shared_nat is false their should be as many public subnets as NAT gatways"
  }
}

output "nat" {
  value = local.nb_nat_gateway
}