# Reverse Proxy Deployment Example

## 🔍 Overview 

This example showcases how to deploy a VM and configure a ready to use reverse proxy with [Caddy](https://caddyserver.com/) on the Outscale cloud platform.

You can either give a quick configuration for the proxy by specifying an address (or domain), a port and the destination backend or give an entire Caddyfile for a more advanced configuration.

## 🧾 Requirements

Before deploying, ensure you have the following installed:

- [Terraform](https://www.terraform.io/downloads.html) (version >= 1.0)
- or [Opentofu](https://github.com/opentofu/opentofu)
- Access to the Outscale cloud platform
- Valid Outscale API credentials

## 📁 Directory Structure

```
templates/outscale/reverse-proxy/
├── main.tf             # Main infrastructure
├── outscale.tf         # Outscale provider configuration
└── variables.tf        # Definitions of input variables for Terraform
```

## 🚀 Deployment Steps

1. Clone the repository:
   ```bash
   git clone https://github.com/chimere-eu/ztiac.git
   cd ztiac/templates/outscale/reverse-proxy
   ```

2. Create a `terraform.tfvars` file with your Outscale credentials and other required variables.


3. Initialize Terraform:
   ```bash
   terraform init
   ```

4. Preview the deployment plan:
   ```bash
   terraform plan
   ```

5. Apply the deployment:
   ```bash
   terraform apply
   ```

## ⚙️ Configuration Details
There are two configuration options for the reverse proxy.
### Quick configuration
You can setup a quick reverse proxy by using the variable 
reverse_proxy with the following parameters:
- address: The address or domain on which the reverse proxy will be accessed 
- port: Port in which the reverse proxy will listen
- upstream: Address and port of the backend server

Example:
```hcl
module "reverse_proxy" {
  source        = "github.com/chimere-eu/ztiac/modules/outscale/compute"
  ...
  reverse_proxy = {
    address = "127.0.0.1"
    port = 443
    upstream = "127.0.0.7:5000" 
   }  
}

```

### Advanced configuration

You also have the possiblity to write a more complex `Caddyfile` and pass it to the reverse_proxy option. For example:
```hcl
module "reverse_proxy" {
  source                = "github.com/chimere-eu/ztiac/modules/outscale/compute"
  ...
  reverse_proxy         = {
    caddyfile = file("./Caddyfile")
  }  
}
```

With a `Caddyfile` like this for example:

```
localhost

file_server
reverse_proxy 127.0.0.1:9005
```

>[!TIP]
> For both configuration methods, if you set a DNS record to the public IP of the VM and open the port 80 to 0.0.0.0/0, you can access the reverse proxy from https://your-domain.com.
> Caddy will automaticly generate and renew SSL certificates for your-domain.com as long as it can perform the HTTP challenge on port 80

## 🧹 Cleanup

To destroy the deployed resources, run:
```bash
terraform destroy
```

## 📌 Notes

>[!TIP]
> Every terraform command can be replaced by opentofu with the same arguments.  
