# Unit: network — VPC with private, public and intra subnets.
#
# Contract
#   values in : catalog, version, name, cidr, tags; optional az_count (3), single_nat_gateway (true)
#   outputs   : vpc_id, vpc_cidr_block, azs, private_subnet_ids, public_subnet_ids, intra_subnet_ids

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${values.catalog}//modules/network?ref=${values.version}"
}

inputs = {
  name               = values.name
  cidr               = values.cidr
  az_count           = try(values.az_count, 3)
  single_nat_gateway = try(values.single_nat_gateway, true)
  cluster_name       = values.name
  tags               = values.tags
}
