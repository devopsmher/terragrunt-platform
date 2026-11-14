output "vpc_id" {
  description = "VPC ID."
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block."
  value       = module.vpc.vpc_cidr_block
}

output "azs" {
  description = "Availability zones in use."
  value       = local.azs
}

output "private_subnet_ids" {
  description = "Private subnets for nodes and workloads."
  value       = module.vpc.private_subnets
}

output "public_subnet_ids" {
  description = "Public subnets for internet-facing load balancers."
  value       = module.vpc.public_subnets
}

output "intra_subnet_ids" {
  description = "Intra subnets for the EKS control plane."
  value       = module.vpc.intra_subnets
}
