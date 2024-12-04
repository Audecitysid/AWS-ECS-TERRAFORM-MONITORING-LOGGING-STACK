variable "account_id" {
  type        = string
  description = "AWS Account ID"
}

variable "env" {
  type        = string
  description = "Environment name"
}

variable "project" {
  type        = string
  description = "Project name"
}

variable "region" {
  type        = string
  description = "AWS Region"
}



# Define a variable to hold the bucket name
variable "bucket_name" {
  type = string
  description = "The name of the S3 bucket used for the Terraform state"
}

variable "table_name" {
  type = string
  description = "The name of the Dynamodb table used "
}