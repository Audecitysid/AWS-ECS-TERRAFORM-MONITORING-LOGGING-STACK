variable "account_id" {
  type        = string
  description = "AWS Account ID"
  default     = "233067124947"
}

variable "env" {
  description = "Environment name"
  default     = "dev"
}

variable "project" {
  description = "Project name"
}

variable "region" {
  description = "AWS Region"
  default     = "us-east-1"
}


variable "docker_image_url_es" {
  type = string
}