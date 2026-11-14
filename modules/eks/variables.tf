variable "name" {
  description = "Cluster name, for example payments-dev."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes minor version, for example 1.35."
  type        = string
}

variable "vpc_id" {
  description = "VPC of the environment."
  type        = string
}

variable "private_subnet_ids" {
  description = "Subnets for nodes and workloads."
  type        = list(string)
}

variable "intra_subnet_ids" {
  description = "Subnets for the control plane network interfaces."
  type        = list(string)
}

variable "admin_role_arns" {
  description = "IAM roles with cluster admin access: the CI apply role and the platform team role."
  type        = list(string)
}

variable "endpoint_public_access" {
  description = "Expose the API endpoint to the internet. Keep false when CI runs inside the VPC or over VPN."
  type        = bool
  default     = false
}

variable "endpoint_public_access_cidrs" {
  description = "CIDR blocks allowed to reach the public API endpoint."
  type        = list(string)
  default     = []
}

variable "system_node_instance_types" {
  description = "Instance types of the small managed node group for Karpenter and cluster add-ons."
  type        = list(string)
  default     = ["m6i.large"]
}

variable "tags" {
  description = "Tags for all resources."
  type        = map(string)
  default     = {}
}
