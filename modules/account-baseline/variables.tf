variable "name" {
  description = "Environment name, for example payments-dev. Used as a prefix for the CI roles."
  type        = string
}

variable "github_repository" {
  description = "Live repository that deploys this environment, in owner/repo form. Only its workflows can assume the CI roles."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$", var.github_repository))
    error_message = "Use the owner/repo form, for example example-org/payments-live."
  }
}

variable "apply_environment" {
  description = "GitHub environment whose jobs may assume the apply role. Protect it with required reviewers."
  type        = string
}

variable "state_bucket" {
  description = "S3 bucket with the Terraform state of this account. The plan role reads state and writes lock files there."
  type        = string
}

variable "apply_role_policy_arns" {
  description = "Managed policies attached to the apply role."
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}

variable "create_github_oidc_provider" {
  description = "Create the GitHub OIDC provider. Set to false when the account already has one."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags for all resources."
  type        = map(string)
  default     = {}
}
