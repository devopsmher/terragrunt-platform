variable "zone_name" {
  description = "Public hosted zone of the environment, for example payments-dev.example.com."
  type        = string

  validation {
    condition     = can(regex("^([a-z0-9-]+\\.)+[a-z]{2,}$", var.zone_name))
    error_message = "Use a lowercase domain name without a trailing dot."
  }
}

variable "tags" {
  description = "Tags for all resources."
  type        = map(string)
  default     = {}
}
