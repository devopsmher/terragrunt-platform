variable "name" {
  description = "Environment name, for example payments-dev."
  type        = string
}

variable "cidr" {
  description = "VPC CIDR block. A /16 leaves room for private, public and intra subnets in every AZ."
  type        = string

  validation {
    condition     = can(cidrhost(var.cidr, 0)) && tonumber(split("/", var.cidr)[1]) <= 16
    error_message = "Use a valid CIDR block of /16 or larger, for example 10.20.0.0/16."
  }
}

variable "az_count" {
  description = "Number of availability zones."
  type        = number
  default     = 3

  validation {
    condition     = var.az_count >= 2 && var.az_count <= 4
    error_message = "Use 2 to 4 availability zones."
  }
}

variable "single_nat_gateway" {
  description = "One NAT gateway for the whole VPC (cheaper, fine for dev) instead of one per AZ."
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "EKS cluster that will run in this VPC. Private subnets get the Karpenter discovery tag for it."
  type        = string
}

variable "tags" {
  description = "Tags for all resources."
  type        = map(string)
  default     = {}
}
