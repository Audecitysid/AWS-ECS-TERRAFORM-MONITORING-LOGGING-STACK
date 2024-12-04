resource "aws_vpc" "main" {
  cidr_block           = var.vpc_ip_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  assign_generated_ipv6_cidr_block = true

  tags = merge(local.common_tags, {
    Name = local.name_prefix
  })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = local.name_prefix
  })
}
