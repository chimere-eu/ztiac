
resource "outscale_public_ip" "this" {
  count = var.enable_nat_gateway ? local.nb_nat_gateway : 0
  tags {
    key   = "name"
    value = "${var.name}-nat-eip-${count.index}"
  }
}