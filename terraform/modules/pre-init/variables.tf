variable "bucket_name" {
  type        = string
  description = "State bucket for the environment being created"
}

variable "table_name" {
  type        = string
  description = "Terraform local table name"
}
