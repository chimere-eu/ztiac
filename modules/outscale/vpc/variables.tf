######################################
# Network
######################################

variable "net_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "region" {
  description = "Region to launch resources"
  type        = string
}

variable "availability_zones" {
  description = "List of availabilty zones to use"
  type        = list(string)
}

variable "name" {
  description = "Name of the network"
  type        = string
}
######################################
# Subnets
######################################

variable "public_subnets" {
  description = "List of public subnet(s) CIDRs"
  type        = list(any)
  default     = []
}

variable "private_subnets" {
  description = "List of private subnet(s) CIDRs"
  type        = list(any)
  default     = []
}

######################################
# NAT Gateway
######################################

variable "enable_nat_gateway" {
  description = "Set to true to create a NAT gateway for private networks"
  type        = bool
  default     = true
}

variable "shared_nat" {
  description = "Wheter or not to deploy a NAT gateway for each AZ. If true a unique NAT gateway is created and shared for all private subnets"
  type        = bool
  default     = false
}

variable "one_nat_gateway_per_az" {
  description = "Wheter or not to limit the number of NAT gateway to one per AZ. If false and share_nat is false, one NAT gateway is created per private subnet."
  type        = bool
  default     = true
}

######################################
# Route Table
######################################

variable "shared_private_route_table" {
  description = "Must be true in order to create only one route table shared by all private subnets. Otherwise each subnet will have its own route table. Note that this can't be set to true if shared_nat is false"
  type        = bool
  default     = false
}

variable "shared_public_route_table" {
  description = "Must be true in order to create only one route table shared by all public subnets. Otherwise each subnet will have its own route table"
  type        = bool
  default     = false
}
