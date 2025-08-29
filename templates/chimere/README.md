# Chimere Example

This example show how to deploy a VM and publish an application using the Zero Trust Network Acess solution [Chimere](https://chimere.eu)
## 🧾 Requirements

Before deploying, ensure you have the following installed:

- [Terraform](https://www.terraform.io/downloads.html) (version >= 1.0)
- or [Opentofu](https://github.com/opentofu/opentofu)
- Access to the Outscale cloud platform
- Valid Outscale API credentials
- A valid Chimere registration key
- An usable OpenBao or Vault to retrieve the registration key


## 📁 Directory Structure

```
templates/chimere/
├── main.tf             # Main infrastructure
├── outscale.tf         # Outscale provider configuration
└── variables.tf        # Definitions of input variables for Terraform
```
## ⚙️ Configuration
To publish your application through Chimere you can use the option `chimere` inside the vm definition and customize the it as needed.
The `chimere` option take a list of the following parameters:
- name: a friendly name for your application
- address: the IPV4 address on which you can reach your service from the VM
- port: the port on which your service is listening
- urls: a list of urls that will be used to access your service
- vault_token: a vault or openbao token to retrieve the secret holding the registration key
- secret_url: full url to the vault/openbao secret from which to retreive the registration key  


```hcl
module "vm" {
  source = "github.com/chimere-eu/ztiac/modules/compute"
  ...
  ...
  ...
  chimere = [{
    # A first application
    name        = "my-ssh-service"
    address     = "127.0.0.1"
    port        = 22
    urls        = ["test.ssh", "something"]
    vault_token = "s.tT2NRwf547tvcZrgRGaeuc4z"
    secret_url  = "http://10.1.0.5:8200/v1/kv/data/secret1"
    },
    {
    # A second application
    name        = "my-web-service"
    address     = "127.0.0.1"
    port        = 80
    urls        = ["service.nginx", "nginx"]
    vault_token = "s.tT2NRwf547tvcZrgRGaeuc4z"
    secret_url  = "http://10.1.0.5:8200/v1/kv/data/secret1"
    }
  ]
}
```

>[!NOTE]
> To make this work their need to be a key/value secret present on a reachable vault/openbao.
> The secret must contain a key named registration_key and the value should be set to a registration key from the chimere manager. 

## 🚀 Deployment Steps

1. Clone the repository:
   ```bash
   git clone https://github.com/chimere-eu/ztiac.git
   cd ztiac/templates/chimere
   ```

2. Create a `terraform.tfvars` file with your Outscale credentials and other required variables.

3. Customize the `chimere` variable to fit your needs.

4. Initialize Terraform:
   ```bash
   terraform init
   ```

5. Preview the deployment plan:
   ```bash
   terraform plan
   ```

6. Apply the deployment:
   ```bash
   terraform apply
   ```

## 🧪 Test the deployment

SSH to the newly deployed VM using the public ip shown by the output of terraform/opentofu.
You should be able to see the list of chimere service running on the server: 

```bash
ssh outscale@<public-ip> -i ./my_key.pem
chimere-service -l
----------------------------------------
Service:        my-web-service
Uuid:           f4460353-9ea1-493d-bd7d-267d96638a7b
IP address:     127.0.0.1
Port:           80
Virtual port:   Not set
Status:         Enabled
----------------------------------------
Service:        my-ssh-service
Uuid:           e01247c9-ac2c-4307-a641-5f97b7f14c4b
IP address:     127.0.0.1
Port:           22
Virtual port:   Not set
Status:         Enabled
```


## 🧹 Cleanup

To destroy the deployed resources, run:
```bash
terraform destroy
```

## 📌 Notes

>[!TIP]
> Every terraform command can be replaced by opentofu with the same arguments.  
