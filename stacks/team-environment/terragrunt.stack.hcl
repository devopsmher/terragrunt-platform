# Stack: team-environment — everything a team needs in its AWS account.
# A live repository passes about ten values; the stack wires the units and their contracts.
#
# values in : catalog, version, team, environment, cidr, zone_name, kubernetes_version,
#             github_repository, state_bucket; optional admin_role_arns

locals {
  name = "${values.team}-${values.environment}"

  tags = {
    Team        = values.team
    Environment = values.environment
    ManagedBy   = "terragrunt"
  }

  units = "${values.catalog}//units"
}

unit "account_baseline" {
  source = "${local.units}/account-baseline?ref=${values.version}"
  path   = "account-baseline"

  values = {
    catalog           = values.catalog
    version           = values.version
    name              = local.name
    github_repository = values.github_repository
    apply_environment = local.name
    state_bucket      = values.state_bucket
    tags              = local.tags
  }
}

unit "network" {
  source = "${local.units}/network?ref=${values.version}"
  path   = "network"

  values = {
    catalog = values.catalog
    version = values.version
    name    = local.name
    cidr    = values.cidr
    tags    = local.tags
  }
}

unit "dns" {
  source = "${local.units}/dns?ref=${values.version}"
  path   = "dns"

  values = {
    catalog   = values.catalog
    version   = values.version
    zone_name = values.zone_name
    tags      = local.tags
  }
}

unit "eks" {
  source = "${local.units}/eks?ref=${values.version}"
  path   = "eks"

  values = {
    catalog               = values.catalog
    version               = values.version
    name                  = local.name
    kubernetes_version    = values.kubernetes_version
    network_path          = "../network"
    account_baseline_path = "../account-baseline"
    admin_role_arns       = try(values.admin_role_arns, [])
    tags                  = local.tags
  }
}
