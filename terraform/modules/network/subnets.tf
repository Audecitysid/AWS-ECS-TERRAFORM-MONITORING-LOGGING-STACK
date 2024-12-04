resource "aws_subnet" "public" {
  count = var.az_num

  vpc_id = aws_vpc.main.id

  availability_zone = element(data.aws_availability_zones.az.names, count.index)
  cidr_block        = cidrsubnet(var.subnet_cidr_public, var.new_bits_public, count.index)
  ipv6_cidr_block   = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, count.index)

  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = format("%s-public-%s",
    local.name_prefix,
    substr(strrev(element(data.aws_availability_zones.az.names, count.index)), 0, 1)
    )
  })
}

resource "aws_subnet" "private" {
  count = var.az_num

  vpc_id = aws_vpc.main.id

  availability_zone = element(data.aws_availability_zones.az.names, count.index)
  cidr_block        = cidrsubnet(var.subnet_cidr_private, var.new_bits_private, count.index)

  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name = format("%s-private-%s",
      local.name_prefix,
      substr(strrev(element(data.aws_availability_zones.az.names, count.index)), 0, 1)
    )
  })
}
