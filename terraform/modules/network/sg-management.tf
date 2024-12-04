resource "aws_security_group" "management" {
  description = "Management"
  name        = "Management"
  vpc_id      = aws_vpc.main.id

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-management"
  })
}

### EGRESS

resource "aws_security_group_rule" "management_egress" {
  description = "Management Egress"
  type        = "egress"
  from_port   = 0
  to_port     = 65535
  protocol    = "all"

  cidr_blocks       = ["0.0.0.0/0"] # tfsec:ignore:AWS007
  security_group_id = aws_security_group.management.id
}

### ICMP

resource "aws_security_group_rule" "management_icmp" {
  description = "Management ICMP"
  type        = "ingress"
  from_port   = -1
  to_port     = -1
  protocol    = "icmp"

  cidr_blocks       = ["0.0.0.0/0"] # tfsec:ignore:AWS006
  security_group_id = aws_security_group.management.id
}

### SSH FROM MANAGEMENT IPS

resource "aws_security_group_rule" "management_ssh" {
  count = length(var.management_ips)

  description = values(var.management_ips)[count.index]
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = [keys(var.management_ips)[count.index]]

  security_group_id = aws_security_group.management.id
}
