terraform {
  backend "s3" {
    bucket         = "terraform-state-aws-es-devops-cloud-wizard-5"
    dynamodb_table = "terraform-state-aws-es-devops-cloud-wizard-5"
    encrypt        = true
    key            = "dev-bastion.tfstate"
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

module "bastion" {
  source = "../../modules/bastion"

  account_id = var.account_id
  env        = var.env
  project    = var.project
  region     = var.region

  volume_size   = 30
  key_name      = "dev-bastion-2"
  instance_type = "t3a.micro"
  image_id      = "ami-0502e817a62226e03"

  sg      = data.terraform_remote_state.network.outputs.sg_management
  subnets = data.terraform_remote_state.network.outputs.subnets_public
}
