# Unit: eks — cluster, system node group and Karpenter with interruption handling.
#
# Contract
#   values in : catalog, version, name, kubernetes_version, network_path, account_baseline_path, tags;
#               optional admin_role_arns (extra cluster admins, for example the platform team role)
#   needs     : network.vpc_id, network.private_subnet_ids, network.intra_subnet_ids,
#               account_baseline.apply_role_arn
#   outputs   : cluster_name, cluster_endpoint, cluster_certificate_authority_data, oidc_provider_arn,
#               node_security_group_id, karpenter_queue_name, karpenter_node_iam_role_name

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${values.catalog}//modules/eks?ref=${values.version}"
}

# Mock outputs let a brand-new environment be planned before its network exists.
# They are never used for apply.
dependency "network" {
  config_path = values.network_path

  mock_outputs = {
    vpc_id             = "vpc-00000000000000000"
    private_subnet_ids = ["subnet-00000000000000001", "subnet-00000000000000002", "subnet-00000000000000003"]
    intra_subnet_ids   = ["subnet-00000000000000004", "subnet-00000000000000005", "subnet-00000000000000006"]
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

dependency "account_baseline" {
  config_path = values.account_baseline_path

  mock_outputs = {
    apply_role_arn = "arn:aws:iam::000000000000:role/mock-ci-apply"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

inputs = {
  name               = values.name
  kubernetes_version = values.kubernetes_version
  vpc_id             = dependency.network.outputs.vpc_id
  private_subnet_ids = dependency.network.outputs.private_subnet_ids
  intra_subnet_ids   = dependency.network.outputs.intra_subnet_ids
  admin_role_arns    = concat([dependency.account_baseline.outputs.apply_role_arn], try(values.admin_role_arns, []))
  tags               = values.tags
}
