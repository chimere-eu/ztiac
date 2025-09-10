resource "outscale_net" "this" {
  ip_range = var.net_cidr
  tags {
    key   = "name"
    value = "${var.name}-net"
  }
}
