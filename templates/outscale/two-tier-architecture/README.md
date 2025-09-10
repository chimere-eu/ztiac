# Two Tier Architecure Example

## 🔍 Overview

This example showcases how to deploy a two tier achitecture on the Outscale cloud platform.
You'll find one private loab balancer serving two instances representing the "backend". One internet facing load balancer serving two instances representing the "frontend". They themselves are pointing to the internal  load balancer.
In addition a bastion is deployed to allow SSH access to the other instances.
The schema below illustrates the architecture:

 <img src="../../docs/images/two_tier_architecture.png" alt="drawing" width="800"/>


## 🧾 Requirements

Before deploying, ensure you have the following installed:

- [Terraform](https://www.terraform.io/downloads.html) (version >= 1.0)
- or [Opentofu](https://github.com/opentofu/opentofu)
- Access to the Outscale cloud platform
- Valid Outscale API credentials

## 📁 Directory Structure

```
templates/outscale/two-tier-architecture/
├── main.tf             # Main infrastructure
├── outscale.tf         # Outscale provider configuration
└── variables.tf        # Definitions of input variables for Terraform
```

## 🚀 Deployment Steps

1. Clone the repository:
   ```bash
   git clone https://github.com/chimere-eu/ztiac.git
   cd ztiac/templates/outscale/two-tier-architecture
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
