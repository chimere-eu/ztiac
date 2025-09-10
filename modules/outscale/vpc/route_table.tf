resource "outscale_route_table" "public" {
  count  = local.nb_public_route_tables
  net_id = local.net_id
  tags {
    key   = "name"
    value = "${var.name}-public-rtb-${count.index}"
  }
}

resource "outscale_route_table_link" "public" {
  count          = local.len_public_subnets
  subnet_id      = outscale_subnet.public[count.index].subnet_id
  route_table_id = element(outscale_route_table.public, count.index).route_table_id
}

resource "outscale_route" "public" {
  count                = local.nb_public_route_tables
  destination_ip_range = "0.0.0.0/0"
  gateway_id           = outscale_internet_service.this.internet_service_id
  route_table_id       = element(outscale_route_table.public, count.index).route_table_id
}


resource "outscale_route_table" "private" {
  count  = local.nb_private_route_tables
  net_id = outscale_net.this.net_id
  tags {
    key   = "name"
    value = "${var.name}-private-rtb-${count.index}"
  }
}

resource "outscale_route_table_link" "private" {
  count          = local.len_private_subnets
  subnet_id      = outscale_subnet.private[count.index].subnet_id
  route_table_id = element(outscale_route_table.private, count.index).route_table_id
}

resource "outscale_route" "private" {
  count                = var.enable_nat_gateway ? local.nb_private_route_tables : 0
  destination_ip_range = "0.0.0.0/0"
  nat_service_id       = element(outscale_nat_service.this, count.index).nat_service_id # var.shared_nat ? outscale_nat_service.this[0].nat_service_id : outscale_nat_service.this[count.index].nat_service_id
  route_table_id       = element(outscale_route_table.private, count.index).route_table_id
}

locals {
  nb_private_route_tables = var.shared_private_route_table ? 1 : local.len_private_subnets
  nb_public_route_tables  = var.shared_public_route_table ? 1 : local.len_public_subnets
  net_id                  = outscale_net.this.net_id
}

check "shared_route_table_and_nat" {
  assert {
    condition     = !(var.shared_private_route_table == true && var.shared_nat == false)
    error_message = "ERROR: Cannot set shared_private_route_table to true with shared_nat set to false "
  }
}
