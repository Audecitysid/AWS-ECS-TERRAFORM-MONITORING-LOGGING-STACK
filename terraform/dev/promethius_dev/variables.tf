variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "Name for the VPC"
  type        = string
  default     = "vpc_nvir"
}

variable "public_subnet_ids" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_ids" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "task_definitions" {
  description = "List of task definition ARNs"
  type = list(object({
    arn = string
  }))
  default = []
}

variable "target_groups" {
  description = "List of target group ARNs"
  type = list(object({
    arn = string
  }))
  default = []
}


variable "docker_image_url" {
  type = string
}

variable "cpu" {
  type = string
}

variable "memory" {
  type = string
}


variable "dcount" {
  type = string
}
