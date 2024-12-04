terraform {
  backend "s3" {
    bucket         = "terraform-state-aws-es-devops-cloud-wizard-5"
    encrypt        = true
    key            = "dev-iam-profile-ecs.tfstate"
    region         = "us-east-1"
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

module "ecs-iam-profile" {
  source = "../../modules/ecs-iam-profile"

  account_id = var.account_id
  env        = var.env
  project    = var.project
  region     = var.region
}
