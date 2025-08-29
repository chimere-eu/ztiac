locals {
  len_public_subnets  = length(var.public_subnets)
  len_private_subnets = length(var.private_subnets)
}

resource "outscale_subnet" "public" {
  count          = local.len_public_subnets
  net_id         = outscale_net.this.net_id
  ip_range       = element(concat(var.public_subnets, [""]), count.index)
  subregion_name = length(regexall("^(${var.region})[a-c]{1}", element(var.availability_zones, count.index))) > 0 ? element(var.availability_zones, count.index) : null
  tags {
    key   = "name"
    value = "${var.name}-public-${count.index}"
  }
}

resource "outscale_subnet" "private" {
  count          = local.len_private_subnets
  net_id         = outscale_net.this.net_id
  ip_range       = element(concat(var.private_subnets, [""]), count.index)
  subregion_name = length(regexall("^(${var.region})[a-c]{1}", element(var.availability_zones, count.index))) > 0 ? element(var.availability_zones, count.index) : null
  tags {
    key   = "name"
    value = "${var.name}-private-${count.index}"
  }
}
