variable "image_id" {
  description = "The ID of the image to use"
  type        = string
}

variable "vm_type" {
  description = "Instance type"
  type        = string
}

variable "keypair_name" {
  description = "SSH key pair name"
  type        = string
}

variable "subnet_id" {
  description = "Subnet to deploy the VM"
  type        = string
}

variable "name" {
  description = "Name tag for the VM"
  type        = string
}

variable "security_group_ids" {
  description = "value"
  type = list(string)
}

variable "block_device_mappings" {
  description = "List of block device mappings"
  type = list(object({
    device_name = string
    bsu = object({
      volume_size           = number
      volume_type           = string
      snapshot_id           = optional(string)
      iops                  = optional(number)
      delete_on_vm_deletion = optional(bool)
    })
  }))
  default = []
}

variable "assign_public_ip" {
  description = "Assign a public IP to the VM if true."
  type = bool
  default = false
}

variable "private_ip" {
  description = "Private IP of the VM. It must be inside the range of the subnet cidr"
  type = string
  default = ""
}

variable "user_data" {
  description = "Data or script used to add a specific configuration to the VM. It must not be Base64-encoded"
  type =  string
  default = null
}

variable "user_data_type" {
  description = "Type of user data entered as input. Must be one of the following: 'shell' or 'cloud-config'"
  type        = string
  default     = "shell"
  validation {
    condition     = contains(["shell", "cloud-config"], var.user_data_type)
    error_message = "Format must be one of: shell, cloud-config."
  }
}

variable "key_file" {
  description = "Path to an extra file that contains ssh public key to add to the VM"
  type = string
  default = null
}

variable "openpubkey" {
  type = object({
    enable             = optional(bool),
    use_providers_file = optional(bool),
    providers_file     = optional(string),
    use_auth_id_file   = optional(bool),
    auth_id_file       = optional(string)
  })
  default = {
    enable             = false,
    use_providers_file = false,
    providers_file     = "providers",
    use_auth_id_file   = false,
    auth_id_file       = "auth_id"
  }
}

variable "chimere" {
  type = list(object({
    name        = string
    address     = string
    port        = number
    vault_token = string
    secret_url  = string
    urls        = list(string)
  }))
  default = null
}

variable "reverse_proxy" {
  type = object({
    address= optional(string)
    port= optional(number)
    upstream= optional(string)
    caddyfile = optional(string)
  })
  default = null
}
