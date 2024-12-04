locals {
  common_tags = {
    Env       = var.env
    ManagedBy = "pre-init"
    Project   = var.project
  }
}
