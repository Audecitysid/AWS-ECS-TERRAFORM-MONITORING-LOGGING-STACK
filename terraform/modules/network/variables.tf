variable "vpc_ip_block" {
  type = string
}

variable "subnet_cidr_public" {
  type = string
}

variable "subnet_cidr_private" {
  type = string
}

variable "new_bits_public" {
  type = number
}

variable "natgw_count" {
  type        = string
  description = "all | none | one"
}

variable "new_bits_private" {
  type = number
}

variable "az_num" {
  type        = number
  description = "Number of used AZ"
}

variable "management_ips" {
  type = map(string)
}

variable "app_direct_access" {
  type = map(map(string))
}