terraform {
  backend "s3" {
    bucket         = "terraform-state-aws-es-devops-cloud-wizard-5"
    encrypt        = true
    key            = "dev-ec2-ecs.tfstate"
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

data "terraform_remote_state" "iam" {
  backend = "s3"

  config = {
    bucket = "terraform-state-aws-es-devops-cloud-wizard-5"
    key    = "dev-iam-profile-ecs.tfstate"
    region = var.region
  }
}

provider "aws" {
  allowed_account_ids = [var.account_id]
  region              = var.region
}

module "ecs-ec2" {
  for_each = {
    app-a = {
      private_ip           = "172.27.72.50",
      az                   = "us-east-1a",
      instance_type        = "t3a.small",
    },
    app-b = {
      private_ip           = "172.27.72.100",
      az                   = "us-east-1b",
      instance_type        = "t3a.small"
    },
    app-c = {
      private_ip           = "172.27.72.150",
      az                   = "us-east-1c",
      instance_type        = "t3a.small"
    },
  }

  source = "../../modules/ecs-ec2"

  account_id = var.account_id
  env        = var.env
  project    = var.project
  region     = var.region

  private_ip           = each.value.private_ip
  volume_size          = 30
  key_name             = "ecs-kp"
  instance_type        = each.value.instance_type
  az                   = each.value.az
  image_id             = "ami-03dbf0c122cb6cf1d"
  name                 = each.key

  profile_name = data.terraform_remote_state.iam.outputs.profile_name
  sg      = data.terraform_remote_state.network.outputs.sg_app
  subnets = data.terraform_remote_state.network.outputs.subnets_private
}
