locals {
  name_prefix = format("%s-%s", var.project, var.env)

  natgw_count = var.natgw_count == "all" ? var.az_num : (var.natgw_count == "one" ? 1 : 0)

  common_tags = {
    Env       = var.env
    ManagedBy = "terraform"
    Project   = var.project
  }
}
