# Syslog Example

This example deploys a simple syslog server as well as a client that will send logs to it on Outscale.

## 🧾 Requirements

Before deploying, ensure you have the following installed:

- [Terraform](https://www.terraform.io/downloads.html) (version >= 1.0)
- or [Opentofu](https://github.com/opentofu/opentofu)
- Access to the Outscale cloud platform
- Valid Outscale API credentials


## 📁 Directory Structure

```
templates/syslog/
├── syslog-server.sh    # Bash script to setup the syslog server
├── syslog-cient.sh     # Bash script to connect the client to the syslog server
├── main.tf             # Main infrastructure
├── outscale.tf         # Outscale provider configuration
└── variables.tf        # Definitions of input variables for Terraform
```

## 🚀 Deployment Steps

1. Clone the repository:
   ```bash
   git clone https://github.com/chimere-eu/ztiac.git
   cd ztiac/templates/syslog
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

## 🧪 Test the Syslog server 

SSH to the syslog server and client using the public ip 

```bash
ssh outscale@<syslog-server-ip> -i ./my_key.pem
ssh outscale@<syslog-client-ip> -i ./my_key.pem
```

From the client VM:

```bash
logger "Test log from CLIENT"
```

Then on the server VM:

```bash
sudo tail /var/log/syslog
```

## 🧹 Cleanup

To destroy the deployed resources, run:
```bash
terraform destroy
```

## 📌 Notes

>[!TIP]
> Every terraform command can be replaced by opentofu with the same arguments.  
