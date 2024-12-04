resource "aws_eip" "ngw" {
  count = local.natgw_count
  vpc   = true

  depends_on = [aws_internet_gateway.igw]

  tags = merge(local.common_tags, {
    Name = format("%s-natgw-%d", local.name_prefix, count.index + 1)
  })
}

resource "aws_nat_gateway" "ngw" {
  count = local.natgw_count

  allocation_id = element(aws_eip.ngw[*].id, count.index)
  subnet_id     = element(aws_subnet.public[*].id, count.index)

  depends_on = [aws_internet_gateway.igw]

  tags = merge(local.common_tags, {
    Name = format("%s-%d", local.name_prefix, count.index + 1)
  })
}
