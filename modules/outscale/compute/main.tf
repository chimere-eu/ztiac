resource "outscale_vm" "this" {
  image_id           = var.image_id
  vm_type            = var.vm_type
  keypair_name       = var.keypair_name
  subnet_id          = var.subnet_id
  security_group_ids = var.security_group_ids
  private_ips        = var.private_ip != "" ? [var.private_ip] : null
  user_data          = data.cloudinit_config.user_data.rendered

  dynamic "block_device_mappings" {
    for_each = var.block_device_mappings
    content {
      device_name = block_device_mappings.value.device_name

      bsu {
        volume_size           = block_device_mappings.value.bsu.volume_size
        volume_type           = block_device_mappings.value.bsu.volume_type
        snapshot_id           = try(block_device_mappings.value.bsu.snapshot_id, null)
        iops                  = try(block_device_mappings.value.bsu.iops, null)
        delete_on_vm_deletion = try(block_device_mappings.value.bsu.delete_on_vm_deletion, null)
      }
    }
  }
  tags {
    key   = "name"
    value = var.name
  }
}

locals {
  ssh_script = (
    var.key_file != null
    ? templatefile("${path.module}/ssh_keys.sh", {
      SSH_KEYS = data.local_file.key_file[0].content
    })
    : ""
  )

  openpubkey = {
    enable             = var.openpubkey.enable != null ? var.openpubkey.enable : false
    use_providers_file = var.openpubkey.use_providers_file != null ? var.openpubkey.use_providers_file : false
    providers_file     = var.openpubkey.providers_file != null ? var.openpubkey.providers_file : "providers"
    use_auth_id_file   = var.openpubkey.use_auth_id_file != null ? var.openpubkey.use_auth_id_file : false
    auth_id_file       = var.openpubkey.auth_id_file != null ? var.openpubkey.auth_id_file : "auth_id"
  }

  content_type_map = {
    "shell"        = "text/x-shellscript"
    "cloud-config" = "text/cloud-config"
  }

  content_type = lookup(local.content_type_map, var.user_data_type, "text/x-shellscript")

  chimere_script = templatefile("${path.module}/chimere.sh", {
    CHIMERE = var.chimere == null ? [] : var.chimere
  })

  caddy_script = templatefile("${path.module}/caddy.sh",
    {
      CADDYFILE = local.caddyfile
  })

  caddyfile = var.reverse_proxy == null ? "" : var.reverse_proxy.caddyfile == null ? local.caddytemplate : var.reverse_proxy.caddyfile

  caddytemplate = var.reverse_proxy == null ? "" : templatefile("${path.module}/Caddyfile", {
    ADDRESS  = var.reverse_proxy.address == null ? "" : var.reverse_proxy.address
    PORT     = var.reverse_proxy.port == null ? "" : var.reverse_proxy.port
    UPSTREAM = var.reverse_proxy.upstream == null ? "" : var.reverse_proxy.upstream
  })
}






data "local_file" "key_file" {
  count    = var.key_file == null ? 0 : 1
  filename = var.key_file
}
data "local_file" "ssh_keys_template" {
  filename = "${path.module}/ssh_keys.sh"
}

data "cloudinit_config" "user_data" {
  gzip          = false
  base64_encode = true

  part {
    filename     = "ssh_keys.sh"
    content_type = "text/x-shellscript"
    content      = var.key_file != null ? local.ssh_script : ""
  }

  part {
    filename     = "openpubkey.sh"
    content_type = "text/x-shellscript"
    content      = local.openpubkey.enable == true ? data.template_file.openpubkey.rendered : ""
  }

  part {
    filename     = var.user_data_type == "shell" ? "user-custom-data.sh" : "user-custom-data.yaml"
    content_type = local.content_type
    content      = var.user_data != null ? var.user_data : ""
  }

  part {
    filename     = "chimere.sh"
    content_type = "text/x-shellscript"
    content      = var.chimere == null ? "" : local.chimere_script
  }

  part {
    filename     = "caddy.sh"
    content_type = "text/x-shellscript"
    content      = var.reverse_proxy == null ? "" : local.caddy_script
  }
}

data "template_file" "openpubkey" {
  template = file("${path.module}/openpubkey.sh")
  vars = {
    "PROVIDERS"          = local.openpubkey.use_providers_file ? file(local.openpubkey.providers_file) : ""
    "AUTH_ID"            = local.openpubkey.use_auth_id_file ? file(local.openpubkey.auth_id_file) : ""
    "USE_PROVIDERS_FILE" = local.openpubkey.use_providers_file
    "USE_AUTH_ID_FILE"   = local.openpubkey.use_auth_id_file

  }
}

##################################################
# Public IP
##################################################
resource "outscale_public_ip" "this" {
  count = var.assign_public_ip ? 1 : 0
}

resource "outscale_public_ip_link" "this" {
  count     = var.assign_public_ip ? 1 : 0
  vm_id     = outscale_vm.this.vm_id
  public_ip = outscale_public_ip.this[0].public_ip
}
