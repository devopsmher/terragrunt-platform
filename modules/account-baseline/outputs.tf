output "plan_role_arn" {
  description = "Read-only role for plans in pull requests."
  value       = aws_iam_role.plan.arn
}

output "apply_role_arn" {
  description = "Role for applies from the protected GitHub environment."
  value       = aws_iam_role.apply.arn
}

output "github_oidc_provider_arn" {
  description = "GitHub OIDC provider used by both CI roles."
  value       = local.github_oidc_provider_arn
}
