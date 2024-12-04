terraform {
  backend "s3" {
    bucket         = "terraform-state-aws-es-devops-cloud-wizard-5"
    dynamodb_table = "terraform-state-aws-es-devops-cloud-wizard-5"
    encrypt        = true
    key            = "dev-ec2.tfstate"
    region         = "eu-central-1"
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "terraform-state-aws-es-devops-cloud-wizard-1"
    key    = "dev-network.tfstate"
    region = var.region
  }
}

provider "aws" {
  allowed_account_ids = [var.account_id]
  region              = var.region
}

module "ec2" {
  for_each = {
    app-a = {
      private_ip           = "172.27.72.50",
      az                   = "us-east-1",
      instance_type        = "t3a.small",
    },
    app-b = {
      private_ip           = "172.27.72.100",
      az                   = "eu-central-1b",
      instance_type        = "t3a.small"
    },
    app-c = {
      private_ip           = "172.27.72.150",
      az                   = "eu-central-1c",
      instance_type        = "t3a.small"
    },
  }

  source = "../../modules/ec2"

  account_id = var.account_id
  env        = var.env
  project    = var.project
  region     = var.region

  private_ip           = each.value.private_ip
  volume_size          = 30
  key_name             = "dev-ec2"
  instance_type        = each.value.instance_type
  az                   = each.value.az
  image_id             = "ami-0502e817a62226e03"
  name                 = each.key

  sg      = data.terraform_remote_state.network.outputs.sg_app
  subnets = data.terraform_remote_state.network.outputs.subnets_private
}
