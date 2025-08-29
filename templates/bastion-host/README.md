# Bastion Example

## 🔍 Overview 

Simple example to deploy a VM and access it through a bastion on the Outscale cloud platform.
The Bastion is assigned a public IP in a public network, the VM to access is located in a private network and accept ssh connection from the bastion exclusively.


## 🧾 Requirements

Before deploying, ensure you have the following installed:

- [Terraform](https://www.terraform.io/downloads.html) (version >= 1.0)
- or [Opentofu](https://github.com/opentofu/opentofu)
- Access to the Outscale cloud platform
- Valid Outscale API credentials

## 📁 Directory Structure

```
templates/bastion-host/
├── main.tf             # Main infrastructure
├── outscale.tf         # Outscale provider configuration
└── variables.tf        # Definitions of input variables for Terraform
```

## 🚀 Deployment Steps

1. Clone the repository:
   ```bash
   git clone https://github.com/chimere-eu/ztiac.git
   cd ztiac/templates/bastion-host
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
