# Outscale Compute Terraform module

Terraform module to create Virtual Machines on Outscale.
Virtual Machines can be customized to add features like ssh using your IDP ([OpenPubKey SSH](https://github.com/openpubkey/opkssh)) or securely publish you application using a Zero Trust Network Access solution [Chimere](https://chimere.eu).
## Usage
 
### Basic single VM
```hcl
module "vm" {
  source             = "github.com/chimere-eu/ztiac/modules/outscale/compute"
  subnet_id          = "subnet-a15ae162"
  security_group_ids = ["sg-50010e30"]
  vm_type            = "tinav5.c2r4p3"
  image_id           = "ami-0ab908cc"
  keypair_name       = "my_keypair"
  name               = "myvm"
}
```
### VM with customized storage
```hcl
module "vm" {
  source                = "github.com/chimere-eu/ztiac/modules/outscale/compute"
  subnet_id             = "subnet-a15ae162"
  security_group_ids    = ["sg-50010e30"]
  vm_type               = "tinav5.c2r4p3"
  image_id              = "ami-0ab908cc"
  keypair_name          = "my_keypair"
  name                  = "myvm"
  block_device_mappings = [ 
    {
      device_name = "/dev/sda1"
      bsu         = {
        volume_size           = 10
        volume_type           = "gp2"
        delete_on_vm_deletion = true
      }
    },
    {
      device_name = "/dev/sdb"
      bsu         = {
        volume_size           = 15
        volume_type           = "gp2"
        delete_on_vm_deletion = true
      }
    }

   ]
}
```

### SSH Key File
This module allows to add ssh public key to the `authorized_keys` file of the first user inside the VM. E.g. `ubuntu` or `outscale` depending on the image.	
```hcl
module "vm" {
  source             = "github.com/chimere-eu/ztiac/modules/outscale/compute"
  subnet_id          = "subnet-a15ae162"
  security_group_ids = ["sg-50010e30"]
  vm_type            = "tinav5.c2r4p3"
  image_id           = "ami-0ab908cc"
  keypair_name       = "my_keypair"
  name               = "myvm"
  key_file           = "./ssh_key_file.pub"
}
```

```
# ssh_key_file.pub
ssh-rsa xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx my_user_1
ssh-rsa xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx my_user_1
ssh-rsa xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx my_user_2
...
```
These three keys (+ the one in the `keypair_name`) can be used to ssh into the VM using the first user of the image.
### OpenPubkey
This module also provides an option to install and configure [OpenPubkey SSH](https://github.com/openpubkey/opkssh) enables to use ssh with OIDC allowing SSH access via identities providers. One can give a `provider` and `auth_id` file to be installed on the VM. Refere to [OpenPubkey SSH's](https://github.com/openpubkey/opkssh) documentation for more information about its configuration.
```hcl
module "vm" {
  source             = "github.com/chimere-eu/ztiac/modules/outscale/compute"
  subnet_id          = "subnet-a15ae162"
  security_group_ids = ["sg-50010e30"]
  vm_type            = "tinav5.c2r4p3"
  image_id           = "ami-0ab908cc"
  keypair_name       = "my_keypair"
  name               = "myvm"
  openpubkey {
    enabled = true
    use_providers_file = true,
    providers_file     = "./providers",
    use_auth_id_file   = true,
    auth_id_file       = "./auth_id"
  }
}
```

```bash
# provider

# Example of custom provider file
https://accounts.google.com 206584157355-7cbe4s640tvm7naoludob4ut1emii7sf.apps.googleusercontent.com 24h
```

```bash
# auth_id

# Example of custom auth_id file 
# email/sub principal issuer
alice alice@example.com https://accounts.google.com

# Group identifier
dev oidc:groups:developer https://login.microsoftonline.com/9188040d-6c67-4c5b-b112-36a304b66dad/v2.0
```
### Chimere
When creating a VM you have the option to install the Chimere agent and set up a the exposition of your application using Chimere.
To make this work a registryation key from Chiere is required and it must me stored inside a Vault or Openbao secret.


The secret must be of type key/value and contain a key named registration_key with the value of the registration key from Chimere.

```hcl
module "vm" {
  source = "github.com/chimere-eu/ztiac/modules/outscale/compute"
  subnet_id ="subnet-3a1bff68"
  security_group_ids = [outscale_security_group.sg.security_group_id]
  vm_type            = var.vm_type
  image_id           = var.image_id
  keypair_name       = outscale_keypair.my_keypair.keypair_name
  name               = "chimere-demo"
  user_data          = <<-EOF
  #!/bin/bash
  apt update
  apt install nginx -y
EOF
  user_data_type     = "shell"
  assign_public_ip   = true
  chimere            = [{
    port        = 22
    vault_token = "s.tT2NRwf547tvcZrgRGaeuc4z"
    secret_url  = "http://10.1.0.5:8200/v1/kv/data/secret1"
    urls        = ["test.ssh", "something"]
    name        = "ssh"
    address     = "127.0.0.1"
    },
    {

    port        = 80
    vault_token = "s.tT2NRwf547tvcZrgRGaeuc4z"
    secret_url  = "http://10.1.0.5:8200/v1/kv/data/secret1"
    urls        = ["service.nginx", "nginx"]
    name        = "web"
    address     = "127.0.0.1"
    }
  ]
}
```
### Reverse Proxy
You can create a VM and set it up in order to installed and configure a reverse proxy with [Caddy](https://caddyserver.com).
Find out more about this in the template [reverse-proxy](../../../templates/outscale/reverse-proxy/README.md).
## Examples

- [Deployement of an OpenBao](../../../templates/outscale/openbao/README.md)
- [Bastion Host](../../../templates/outscale/openbao/README.md)
- [Usage of Openpubkey](../../../templates/outscale/openpubkey/README.md)
- [With Chimere](../../../templates/outscale/chimere/README.md)
- [With Syslog](../../../templates/outscale/syslog/README.md)
- [With a reverse proxy](../../../templates/outscale/reverse-proxy/README.md)

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_cloudinit"></a> [cloudinit](#provider\_cloudinit) | n/a |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |
| <a name="provider_outscale"></a> [outscale](#provider\_outscale) | n/a |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [outscale_public_ip.this](https://registry.terraform.io/providers/outscale/outscale/latest/docs/resources/public_ip) | resource |
| [outscale_public_ip_link.this](https://registry.terraform.io/providers/outscale/outscale/latest/docs/resources/public_ip_link) | resource |
| [outscale_vm.this](https://registry.terraform.io/providers/outscale/outscale/latest/docs/resources/vm) | resource |
| [cloudinit_config.user_data](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |
| [local_file.key_file](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.ssh_keys_template](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [template_file.openpubkey](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_assign_public_ip"></a> [assign\_public\_ip](#input\_assign\_public\_ip) | Assign a public IP to the VM if true. | `bool` | `false` | no |
| <a name="input_block_device_mappings"></a> [block\_device\_mappings](#input\_block\_device\_mappings) | List of block device mappings | <pre>list(object({<br/>    device_name = string<br/>    bsu = object({<br/>      volume_size           = number<br/>      volume_type           = string<br/>      snapshot_id           = optional(string)<br/>      iops                  = optional(number)<br/>      delete_on_vm_deletion = optional(bool)<br/>    })<br/>  }))</pre> | `[]` | no |
| <a name="input_chimere"></a> [chimere](#input\_chimere) | n/a | <pre>list(object({<br/>    name        = string<br/>    address     = string<br/>    port        = number<br/>    vault_token = string<br/>    secret_url  = string<br/>    urls        = list(string)<br/>  }))</pre> | `null` | no |
| <a name="input_image_id"></a> [image\_id](#input\_image\_id) | The ID of the image to use | `string` | n/a | yes |
| <a name="input_key_file"></a> [key\_file](#input\_key\_file) | Path to an extra file that contains ssh public key to add to the VM | `string` | `null` | no |
| <a name="input_keypair_name"></a> [keypair\_name](#input\_keypair\_name) | SSH key pair name | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name tag for the VM | `string` | n/a | yes |
| <a name="input_openpubkey"></a> [openpubkey](#input\_openpubkey) | n/a | <pre>object({<br/>    enable             = optional(bool),<br/>    use_providers_file = optional(bool),<br/>    providers_file     = optional(string),<br/>    use_auth_id_file   = optional(bool),<br/>    auth_id_file       = optional(string)<br/>  })</pre> | <pre>{<br/>  "auth_id_file": "auth_id",<br/>  "enable": false,<br/>  "providers_file": "providers",<br/>  "use_auth_id_file": false,<br/>  "use_providers_file": false<br/>}</pre> | no |
| <a name="input_private_ip"></a> [private\_ip](#input\_private\_ip) | Private IP of the VM. It must be inside the range of the subnet cidr | `string` | `""` | no |
| <a name="input_reverse_proxy"></a> [reverse\_proxy](#input\_reverse\_proxy) | n/a | <pre>object({<br/>    address= optional(string)<br/>    port= optional(number)<br/>    upstream= optional(string)<br/>    caddyfile = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | value | `list(string)` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet to deploy the VM | `string` | n/a | yes |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | Data or script used to add a specific configuration to the VM. It must not be Base64-encoded | `string` | `null` | no |
| <a name="input_user_data_type"></a> [user\_data\_type](#input\_user\_data\_type) | Type of user data entered as input. Must be one of the following: 'shell' or 'cloud-config' | `string` | `"shell"` | no |
| <a name="input_vm_type"></a> [vm\_type](#input\_vm\_type) | Instance type | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | ID of the VM |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | Private IP of the VM |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | Public IP of the VM |
| <a name="output_user_data"></a> [user\_data](#output\_user\_data) | n/a |