terraform {
  backend "s3" {
    bucket         = "terraform-state-aws-es-devops-cloud-wizard-5"
    dynamodb_table = "terraform-state-aws-es-devops-cloud-wizard-5"
    encrypt        = true
    key            = "dev-opensearch.tfstate"
    region         = "eu-central-1"
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "terraform-state-aws-es-devops-cloud-wizard-5"
    key    = "dev-network.tfstate"
    region = var.region
  }
}

provider "aws" {
  allowed_account_ids = [var.account_id]
  region              = var.region
}

module "opensearch" {
  source = "../../modules/opensearch"
  account_id = var.account_id
  env        = var.env
  project    = var.project
  region     = var.region

  subnets = data.terraform_remote_state.network.outputs.subnets_private
  sg      = data.terraform_remote_state.network.outputs.sg_es

  domain_name                   = "opensearch-dev"
  versionES                     = "OpenSearch_1.3"
  instance_type                 = "t3.small.search"
  instance_count                = 2
  az_count			= 2
  volume_size                   = 10 # Source Data * (1 + Number of Replicas) * 1.45 = Minimum Storage Requirement
  automated_snapshot_start_hour = 23 #
}


