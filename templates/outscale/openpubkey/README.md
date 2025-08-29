# OpenPubkey Example

This example deploys a VM on outscale cloud with [OpenPubkey SSH](https://github.com/openpubkey/opkssh) (opkssh) installed and configured. Opkssh is a tool which enables ssh to be used with OpenID Connect allowing SSH access to be managed via identity providers.

## 🧾 Requirements

Before deploying, ensure you have the following installed:

- [Terraform](https://www.terraform.io/downloads.html) (version >= 1.0)
- or [Opentofu](https://github.com/opentofu/opentofu)
- Access to the Outscale cloud platform
- Valid Outscale API credentials


## 📁 Directory Structure

```
templates/outscale/openpubkey/
├── auth_id             # opkssh configuration file determining which identities are allowed to connect to what linux user accounts
├── providers           # opkssh configuration file containing a list of allowed IDPs 
├── main.tf             # Main infrastructure
├── outscale.tf         # Outscale provider configuration
└── variables.tf        # Definitions of input variables for Terraform
```

## 🚀 Deployment Steps

1. Clone the repository:
   ```bash
   git clone https://github.com/chimere-eu/ztiac.git
   cd ztiac/templates/outscale/openpubkey
   ```

2. Create a `terraform.tfvars` file with your Outscale credentials and other required variables.

3. Customize the `auth_id` and `providers` files with the desired user and IDP.
>[!TIP]
> To get more information about setting up user access or IDP settings, refer to the [OpenPubkey SSH](https://github.com/openpubkey/opkssh) documentation.

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

## 🧪 Accessing the VM using OpenPubkey ssh

After downloading opkssh run:
```
opkssh login
```
and login to the IDP you configured in the `auth_id` file.
For example if this was the auth_id file:
> alice alice@example.com https://accounts.google.com
> 
you would login with the google account `alice@example.com` and then ssh using the user alice:
```bash
ssh alice@<server-ip> 
```

## 🧹 Cleanup

To destroy the deployed resources, run:
```bash
terraform destroy
```

## 📌 Notes

>[!TIP]
> Every terraform command can be replaced by opentofu with the same arguments.  
