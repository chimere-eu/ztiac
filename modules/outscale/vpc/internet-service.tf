resource "outscale_internet_service" "this" {
  tags {
    key   = "name"
    value = "${var.name}-igw"
  }
}

resource "outscale_internet_service_link" "this" {
  internet_service_id = outscale_internet_service.this.internet_service_id
  net_id              = outscale_net.this.net_id
}
