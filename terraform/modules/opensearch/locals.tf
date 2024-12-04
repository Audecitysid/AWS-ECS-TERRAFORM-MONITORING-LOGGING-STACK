locals {
  name_prefix = format("%s-%s", var.project, var.env)

  common_tags = {
    Env       = var.env
    ManagedBy = "terraform"
    Project   = var.project
  }
}
