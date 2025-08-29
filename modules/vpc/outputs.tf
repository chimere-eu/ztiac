output "vpc_id" {
  value       = outscale_net.this.net_id
  description = "ID of the network"
}

output "vpc_cidr" {
  value       = outscale_net.this.ip_range
  description = "CIDR of the network"
}

output "private_subnets" {
  value       = length(var.private_subnets) != 0 ? { for i in range(length(var.private_subnets)) : "private-${i}" => { "id" : outscale_subnet.private[i].subnet_id, "name" : [for item in outscale_subnet.private[i].tags : item.value if item.key == "name"][0],
                      "cidr" : outscale_subnet.private[i].ip_range } } : null
  description = "List of ID and name of the private subnet(s)"
}

output "public_subnets" {
  value       = { for i in range(length(var.public_subnets)) : "public-${i}" => { "id" : outscale_subnet.public[i].subnet_id, "name" : [for item in outscale_subnet.public[i].tags : item.value if item.key == "name"][0],
                      "cidr" : outscale_subnet.public[i].ip_range } }
  description = "List of ID and name of the public subnet(s)"
}

output "nat_gateways" {
  value = local.nb_nat_gateway != 0 ? { for i in range(local.nb_nat_gateway) : "nat-gtw-${i}" => { "id" : element(outscale_nat_service.this, i).nat_service_id,
    "name" : [for item in outscale_subnet.private[i].tags : item.value if item.key == "name"][0],
  "ip" : element(outscale_nat_service.this, i).public_ips[0].public_ip } } : null
  description = "List of ID, name and IP of the NAT gateway(s)"
}

output "internet_service_id" {
  value       = outscale_internet_service.this.internet_service_id
  description = "ID of the internet service"
}

output "private_rtb" {
  value = { for i in range(local.nb_private_route_tables) : "private-${i}" => { "id" : outscale_route_table.private[i].route_table_id, "name" : [for item in outscale_route_table.private[i].tags : item.value if item.key == "name"][0] } }
  description = "List of ID and name of the private route table(s)"
}

output "public_rtb" {
  value = { for i in range(local.nb_public_route_tables) : "public-${i}" => { "id" : outscale_route_table.public[i].route_table_id, "name" : [for item in outscale_route_table.public[i].tags : item.value if item.key == "name"][0] } }
  description = "List of ID and name of the public route table(s)"
}