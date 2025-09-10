terraform {
  required_version = ">= 1.0"
  required_providers {
    outscale = {
      source  = "outscale/outscale"
      version = ">= 1.1.3"
    }
    local = {
      source  = "hashicorp/local"
      version = ">=2.5.0"
    }
    template = {
      source  = "hashicorp/template"
      version = ">=2.2.0"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = ">=2.3.0"
    }
  }
}
