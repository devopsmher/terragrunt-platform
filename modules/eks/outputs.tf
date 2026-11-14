output "cluster_name" {
  description = "Cluster name."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "API server endpoint."
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 cluster CA certificate."
  value       = module.eks.cluster_certificate_authority_data
}

output "oidc_provider_arn" {
  description = "IRSA OIDC provider of the cluster."
  value       = module.eks.oidc_provider_arn
}

output "node_security_group_id" {
  description = "Security group shared by nodes; Karpenter discovers it by tag."
  value       = module.eks.node_security_group_id
}

output "karpenter_queue_name" {
  description = "SQS queue with interruption events for the Karpenter controller."
  value       = module.karpenter.queue_name
}

output "karpenter_node_iam_role_name" {
  description = "IAM role for nodes launched by Karpenter."
  value       = module.karpenter.node_iam_role_name
}
