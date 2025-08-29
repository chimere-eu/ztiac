# VPC with NAT Example

## 🔍 Overview 

Simple example to deploy a VPC with public/private network and NAT gateways to access internet from the private network on the Outscale cloud platform.


## 🧾 Requirements

Before deploying, ensure you have the following installed:

- [Terraform](https://www.terraform.io/downloads.html) (version >= 1.0)
- or [Opentofu](https://github.com/opentofu/opentofu)
- Access to the Outscale cloud platform
- Valid Outscale API credentials

## 📁 Directory Structure

```
templates/outscale/vpc-with-nat/
├── main.tf             # Main infrastructure
├── outscale.tf         # Outscale provider configuration
└── variables.tf        # Definitions of input variables for Terraform
```

## 🚀 Deployment Steps

1. Clone the repository:
   ```bash
   git clone https://github.com/chimere-eu/ztiac.git
   cd ztiac/templates/outscale/vpc-with-nat
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

## 🧹 Cleanup

To destroy the deployed resources, run:
```bash
terraform destroy
```

## 📌 Notes

>[!TIP]
> Every terraform command can be replaced by opentofu with the same arguments.  
