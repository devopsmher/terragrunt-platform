# Unit: account-baseline — secure defaults and keyless CI roles for one AWS account.
#
# Contract
#   values in : catalog, version, name, github_repository, apply_environment, state_bucket, tags
#   outputs   : plan_role_arn, apply_role_arn, github_oidc_provider_arn

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${values.catalog}//modules/account-baseline?ref=${values.version}"
}

inputs = {
  name              = values.name
  github_repository = values.github_repository
  apply_environment = values.apply_environment
  state_bucket      = values.state_bucket
  tags              = values.tags
}
