# Network Example

This example shows the how to create muliple network using the module VPC.
It include two networks with each having their own public and private subnets as well as an example of NAT and internet gateway setup.
In this example these two networks are peered with each other allowing communication between their subnets.
Finally an example of DMZ network is created.
The image below illustrate this network example:
 <img src="../../docs/images/network_example.png" alt="drawing" width="1000"/>

## 🧾 Requirements

Before deploying, ensure you have the following installed:

- [Terraform](https://www.terraform.io/downloads.html) (version >= 1.0)
- or [Opentofu](https://github.com/opentofu/opentofu)
- Access to the Outscale cloud platform
- Valid Outscale API credentials


## 📁 Directory Structure

```
templates/outscale/advanced-network/
├── main.tf             # Main infrastructure
├── outscale.tf         # Outscale provider configuration
└── variables.tf        # Definitions of input variables for Terraform
```

## 🚀 Deployment Steps

1. Clone the repository:
   ```bash
   git clone https://github.com/chimere-eu/ztiac.git
   cd ztiac/templates/outscale/advanced-network
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Preview the deployment plan:
   ```bash
   terraform plan
   ```

4. Apply the deployment:
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
