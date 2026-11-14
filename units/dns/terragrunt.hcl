# Unit: dns — public hosted zone of the environment.
#
# Contract
#   values in : catalog, version, zone_name, tags
#   outputs   : zone_id, zone_name, name_servers

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${values.catalog}//modules/dns?ref=${values.version}"
}

inputs = {
  zone_name = values.zone_name
  tags      = values.tags
}
