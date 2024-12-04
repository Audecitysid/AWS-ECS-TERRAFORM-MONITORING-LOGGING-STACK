variable "subnets" {
  type = set(object({
    arn                             = string
    assign_ipv6_address_on_creation = bool
    availability_zone               = string
    availability_zone_id            = string
    cidr_block                      = string
    id                              = string
    ipv6_cidr_block                 = string
    ipv6_cidr_block_association_id  = string
    map_public_ip_on_launch         = bool
    outpost_arn                     = string
    owner_id                        = string
    tags                            = map(string)
    timeouts                        = map(string)
    vpc_id                          = string
  }))
}

variable "sg" {
  type = object({
    arn         = string
    description = string
    egress = set(object({
      cidr_blocks      = list(string)
      description      = string
      from_port        = number
      ipv6_cidr_blocks = list(string)
      prefix_list_ids  = list(string)
      protocol         = string
      security_groups  = set(string)
      self             = bool
      to_port          = number
    }))
    id = string
    ingress = set(object({
      cidr_blocks      = list(string)
      description      = string
      from_port        = number
      ipv6_cidr_blocks = list(string)
      prefix_list_ids  = list(string)
      protocol         = string
      security_groups  = set(string)
      self             = bool
      to_port          = number
    }))
    name                   = string
    name_prefix            = string
    owner_id               = string
    revoke_rules_on_delete = bool
    tags                   = map(string)
    timeouts               = map(string)
    vpc_id                 = string
  })
}

variable "domain_name" {
  type = string
}

variable "versionES" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "instance_count" {
  type = number
}

variable "az_count" {
  type = number
}

variable "volume_size" {
  type = number
}

variable "automated_snapshot_start_hour" {
  type = string
}
