# Outscale Compute Terraform module

Terraform module to create Networks on Outscale.

# Usage

```hcl
module "vpc" {
  source                     = "github.com/chimere-eu/ztiac/modules/outscale/vpc"
  name                       = "my-network"
  availability_zones         = [ "cloudgouv-eu-west-1a", "cloudgouv-eu-west-1b", "cloudgouv-eu-west-1c" ]
  region                     = "cloudgouv-eu-west"
  net_cidr                   = "10.1.0.0/16"
  public_subnets             = [ "10.1.0.0/24", "10.1.1.0/24" ]
  private_subnets            = [ "10.1.2.0/24", "10.1.3.0/24" ]
}
```
## Customize the NAT gateway setup

There are three scenerios for creating NAT gateway:
  - One NAT gateway is created per availablity zone (default)
  - One NAT gateway is created per subnet
  - One single NAT gateway is shared by all private subnets of the network
### One NAT gateway per AZ (default)
Here subnets are created across 3 AZs and one NAT gateway will be created for each one of them.

>[!WARNING]
>As NAT services need to be created inside a public subnet there must be at least as many public subnets as avaibility zones.

```hcl
module "vpc" {
  source             = "github.com/chimere-eu/ztiac/modules/outscale/vpc"
  name               = "my-network"
  availability_zones = [ "cloudgouv-eu-west-1a", "cloudgouv-eu-west-1b", "cloudgouv-eu-west-1c" ]
  region             = "cloudgouv-eu-west"
  net_cidr           = "10.1.0.0/16"
  public_subnets     = [ "10.1.0.0/24", "10.1.1.0/24", 10.1.2.0/24 ]
  private_subnets    = [ "10.1.3.0/24", "10.1.4.0/24", 10.1.5.0/24 ]
  enable_nat_gateway = true
  shared_nat         = false
  one_nat_per_az     = true
}
```

 <img src="../../docs/images/one_nat_gateway_per_az.png" alt="drawing" width="400"/>

### One NAT gateway per subnet
Here there are as many NAT gateway that there are subnets

>[!WARNING]
>As NAT services need to be created inside a public subnet there must be at least as many public subnets as private subnets.

```hcl
module "vpc" {
  source             = "github.com/chimere-eu/ztiac/modules/outscale/vpc"
  name               = "my-network"
  availability_zones = [ "cloudgouv-eu-west-1a", "cloudgouv-eu-west-1b", "cloudgouv-eu-west-1c" ]
  region             = "cloudgouv-eu-west"
  net_cidr           = "10.1.0.0/16"
  public_subnets     = [ "10.1.0.0/24", "10.1.1.0/24", 10.1.2.0/24, "10.1.3.0/24" ]
  private_subnets    = [ "10.1.4.0/24", "10.1.5.0/24", 10.1.6.0/24, "10.1.7.0/24" ]
  enable_nat_gateway = true
  shared_nat         = false
  one_nat_per_az     = false
}
```

 <img src="../../docs/images/one_nat_gateway_per_subnet.png" alt="drawing" width="400"/>

### One Single NAT gateway
Here a single NAT gateway is created and shared among all the private subntes.
```hcl
module "vpc" {
  source             = "github.com/chimere-eu/ztiac/modules/outscale/vpc"
  name               = "my-network"
  availability_zones = [ "cloudgouv-eu-west-1a", "cloudgouv-eu-west-1b", "cloudgouv-eu-west-1c" ]
  region             = "cloudgouv-eu-west"
  net_cidr           = "10.1.0.0/16"
  public_subnets     = [ "10.1.0.0/24", "10.1.1.0/24", 10.1.2.0/24 ]
  private_subnets    = [ "10.1.3.0/24", "10.1.4.0/24", 10.1.5.0/24 ]
  enable_nat_gateway = true
  shared_nat         = true
}
```
>[!NOTE]
>If both `one_nat_per_az` and `share_nat` are set to true, `share_nat` takes precedence and one NAT gateway wil be created in the first availability zone.

 <img src="../../docs/images/single_nat_gateway.png" alt="drawing" width="400"/>

## Route tables

Similar to the NAT gateway scenarios, you have two options for the route tables of the private and public subnets. All public and private subnets can either:
  - have their own route table (default)
  - have one route table shared across all private subnets and/or one route table shared across all public subnets.

```hcl
module "vpc" {
  source                     = "github.com/chimere-eu/ztiac/modules/outscale/vpc"
  name                       = "my-network"
  availability_zones         = [ "cloudgouv-eu-west-1a", "cloudgouv-eu-west-1b", "cloudgouv-eu-west-1c" ]
  region                     = "cloudgouv-eu-west"
  net_cidr                   = "10.1.0.0/16"
  public_subnets             = [ "10.1.0.0/24", "10.1.1.0/24", 10.1.2.0/24 ]
  private_subnets            = [ "10.1.3.0/24", "10.1.4.0/24", 10.1.5.0/24 ]
  shared_private_route_table = true
  shared_public_route_table  = true
}
```

TO DO:

- Add internal subnet example
- Add extarnal IP support for NAT

## Examples

- [Basic network example](../../../templates/outscale/vpc-with-nat/README.md)
- [Advanced exmaple with net peering and a DMZ](../../../templates/outscale/advanced-network/README.md)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_outscale"></a> [outscale](#requirement\_outscale) | >= 1.1.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_outscale"></a> [outscale](#provider\_outscale) | >= 1.1.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [outscale_internet_service.this](https://registry.terraform.io/providers/outscale/outscale/latest/docs/resources/internet_service) | resource |
| [outscale_internet_service_link.this](https://registry.terraform.io/providers/outscale/outscale/latest/docs/resources/internet_service_link) | resource |
| [outscale_nat_service.this](https://registry.terraform.io/providers/outscale/outscale/latest/docs/resources/nat_service) | resource |
| [outscale_net.this](https://registry.terraform.io/providers/outscale/outscale/latest/docs/resources/net) | resource |
| [outscale_public_ip.this](https://registry.terraform.io/providers/outscale/outscale/latest/docs/resources/public_ip) | resource |
| [outscale_route.private](https://registry.terraform.io/providers/outscale/outscale/latest/docs/resources/route) | resource |
| [outscale_route.public](https://registry.terraform.io/providers/outscale/outscale/latest/docs/resources/route) | resource |
| [outscale_route_table.private](https://registry.terraform.io/providers/outscale/outscale/latest/docs/resources/route_table) | resource |
| [outscale_route_table.public](https://registry.terraform.io/providers/outscale/outscale/latest/docs/resources/route_table) | resource |
| [outscale_route_table_link.private](https://registry.terraform.io/providers/outscale/outscale/latest/docs/resources/route_table_link) | resource |
| [outscale_route_table_link.public](https://registry.terraform.io/providers/outscale/outscale/latest/docs/resources/route_table_link) | resource |
| [outscale_subnet.private](https://registry.terraform.io/providers/outscale/outscale/latest/docs/resources/subnet) | resource |
| [outscale_subnet.public](https://registry.terraform.io/providers/outscale/outscale/latest/docs/resources/subnet) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | List of availabilty zones to use | `list(string)` | n/a | yes |
| <a name="input_enable_nat_gateway"></a> [enable\_nat\_gateway](#input\_enable\_nat\_gateway) | Set to true to create a NAT gateway for private networks | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the network | `string` | n/a | yes |
| <a name="input_net_cidr"></a> [net\_cidr](#input\_net\_cidr) | CIDR block for the VPC | `string` | n/a | yes |
| <a name="input_one_nat_gateway_per_az"></a> [one\_nat\_gateway\_per\_az](#input\_one\_nat\_gateway\_per\_az) | Wheter or not to limit the number of NAT gateway to one per AZ. If false and share\_nat is false, one NAT gateway is created per private subnet. | `bool` | `true` | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | List of private subnet(s) CIDRs | `list(any)` | `[]` | no |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | List of public subnet(s) CIDRs | `list(any)` | `[]` | no |
| <a name="input_region"></a> [region](#input\_region) | Region to launch resources | `string` | n/a | yes |
| <a name="input_shared_nat"></a> [shared\_nat](#input\_shared\_nat) | Wheter or not to deploy a NAT gateway for each AZ. If true a unique NAT gateway is created and shared for all private subnets | `bool` | `false` | no |
| <a name="input_shared_private_route_table"></a> [shared\_private\_route\_table](#input\_shared\_private\_route\_table) | Must be true in order to create only one route table shared by all private subnets. Otherwise each subnet will have its own route table. Note that this can't be set to true if shared\_nat is false | `bool` | `false` | no |
| <a name="input_shared_public_route_table"></a> [shared\_public\_route\_table](#input\_shared\_public\_route\_table) | Must be true in order to create only one route table shared by all public subnets. Otherwise each subnet will have its own route table | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_internet_service_id"></a> [internet\_service\_id](#output\_internet\_service\_id) | ID of the internet service |
| <a name="output_nat_gateways"></a> [nat\_gateways](#output\_nat\_gateways) | List of ID, name and IP of the NAT gateway(s) |
| <a name="output_private_rtb"></a> [private\_rtb](#output\_private\_rtb) | List of ID and name of the private route table(s) |
| <a name="output_private_subnets"></a> [private\_subnets](#output\_private\_subnets) | List of ID and name of the private subnet(s) |
| <a name="output_public_rtb"></a> [public\_rtb](#output\_public\_rtb) | List of ID and name of the public route table(s) |
| <a name="output_public_subnets"></a> [public\_subnets](#output\_public\_subnets) | List of ID and name of the public subnet(s) |
| <a name="output_vpc_cidr"></a> [vpc\_cidr](#output\_vpc\_cidr) | CIDR of the network |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID of the network |
<!-- END_TF_DOCS -->
