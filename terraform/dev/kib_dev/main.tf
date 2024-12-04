provider "aws" {
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = "~> 1.2"
}


data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "terraform-state-aws-es-devops-cloud-wizard-5"
    key    = "dev-network.tfstate"
    region = "us-east-1"
  }
}


data "terraform_remote_state" "ecs_cluster" {
  backend = "s3"
  config = {
    bucket = "terraform-state-aws-es-devops-cloud-wizard-5"
    key    = "dev-cluster-ecs.tfstate"
    region = "us-east-1"
  }
}



module "ecs" {
  source             =  "../../modules/kib_mod/ecs"
  vpc_id             = data.terraform_remote_state.network.outputs.vpc.id
  public_subnets     = data.terraform_remote_state.network.outputs.public_subnet_ids
  private_subnets    = data.terraform_remote_state.network.outputs.private_subnet_ids
  
  task_definitions   = var.task_definitions
  target_groups      = var.target_groups
  existing_security_group     = data.terraform_remote_state.ecs_cluster.outputs.sg_alb_id

  availability_zones = var.availability_zones
  docker_image_url   = var.docker_image_url
  cpu                = var.cpu
  memory             = var.memory
  dcount             = var.dcount


  # Pass the ALB ARN from the ECS module
  alb_arn = data.terraform_remote_state.ecs_cluster.outputs.alb_arn

}

