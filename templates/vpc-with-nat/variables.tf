variable "region" {
  default     = "cloudgouv-eu-west-1"
  type        = string
  description = "Outscale region on which resources are deployed"
}

variable "profile" {
  default     = "default"
  type        = string
  description = "Profile to use if you use a config file for the Outscale credentials"
}
