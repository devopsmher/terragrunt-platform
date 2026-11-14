# Root configuration of a live repository, shared by every unit.
# Each environment directory has an env.hcl with its AWS account and region.

locals {
  env        = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_id = local.env.locals.account_id
  region     = local.env.locals.region

  # Generated stacks live under .terragrunt-stack/; drop it from state keys to keep them readable:
  # payments/dev/platform/network/terraform.tfstate
  state_key = replace(path_relative_to_include(), "/.terragrunt-stack", "")
}

remote_state {
  backend = "s3"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket       = "tfstate-${local.account_id}-${local.region}"
    key          = "${local.state_key}/terraform.tfstate"
    region       = local.region
    encrypt      = true
    use_lockfile = true
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "aws" {
      region              = "${local.region}"
      allowed_account_ids = ["${local.account_id}"]
    }
  EOF
}
