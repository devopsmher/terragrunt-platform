# Network: one VPC per team environment.
#   private subnets — workloads and nodes, tagged for internal load balancers and Karpenter;
#   public subnets  — internet-facing load balancers and NAT gateways;
#   intra subnets   — EKS control plane network interfaces, no internet route.

data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.7.3"

  name = var.name
  cidr = var.cidr
  azs  = local.azs

  private_subnets = [for index, az in local.azs : cidrsubnet(var.cidr, 4, index)]
  public_subnets  = [for index, az in local.azs : cidrsubnet(var.cidr, 8, index + 48)]
  intra_subnets   = [for index, az in local.azs : cidrsubnet(var.cidr, 8, index + 52)]

  enable_nat_gateway     = true
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = !var.single_nat_gateway

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    "karpenter.sh/discovery"          = var.cluster_name
  }

  tags = var.tags
}
