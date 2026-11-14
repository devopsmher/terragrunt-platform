# Payments team, dev environment. This file is all a team writes to get an environment.

locals {
  env     = read_terragrunt_config("env.hcl")
  catalog = get_env("PLATFORM_CATALOG", "git::https://github.com/devopsmher/terragrunt-platform.git")
  version = "v0.1.0"
}

stack "platform" {
  source = "${local.catalog}//stacks/team-environment?ref=${local.version}"
  path   = "platform"

  values = {
    catalog            = local.catalog
    version            = local.version
    team               = "payments"
    environment        = "dev"
    cidr               = "10.20.0.0/16"
    zone_name          = "payments-dev.example.com"
    kubernetes_version = "1.35"
    github_repository  = "example-org/payments-live"
    state_bucket       = "tfstate-${local.env.locals.account_id}-${local.env.locals.region}"
  }
}
