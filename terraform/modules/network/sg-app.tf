resource "aws_security_group" "app" {
  description = "App"
  name        = "App"
  vpc_id      = aws_vpc.main.id

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-app"
  })
}

### EGRESS

resource "aws_security_group_rule" "app_egress" {
  description = "App Egress"
  type        = "egress"
  from_port   = 0
  to_port     = 65535
  protocol    = "all"

  cidr_blocks       = ["0.0.0.0/0"] # tfsec:ignore:AWS007
  security_group_id = aws_security_group.app.id
}

### ICMP

resource "aws_security_group_rule" "app_icmp" {
  description = "App ICMP"
  type        = "ingress"
  from_port   = -1
  to_port     = -1
  protocol    = "icmp"

  cidr_blocks       = ["0.0.0.0/0"] # tfsec:ignore:AWS006
  security_group_id = aws_security_group.app.id
}

### FROM MANAGEMENT

resource "aws_security_group_rule" "app_management" {
  description = "From Management"
  type        = "ingress"
  from_port   = 0
  to_port     = 65535
  protocol    = "tcp"

  security_group_id        = aws_security_group.app.id
  source_security_group_id = aws_security_group.management.id
}

### FROM ALB

//resource "aws_security_group_rule" "app_alb" {
//  count = length(var.app_ports)
//
//  description = "From ALB"
//  type        = "ingress"
//  from_port   = element(var.app_ports, count.index)
//  to_port     = element(var.app_ports, count.index)
//  protocol    = "tcp"
//
//  security_group_id        = aws_security_group.app.id
//  source_security_group_id = aws_security_group.alb.id
//}

### FROM ITSELF

resource "aws_security_group_rule" "app_self" {
  description = "From itself"
  type        = "ingress"
  from_port   = 0
  to_port     = 65535
  protocol    = "all"

  self              = true
  security_group_id = aws_security_group.app.id
}

### DIRECT ACCESS

resource "aws_security_group_rule" "app_vpn" {
  for_each = var.app_direct_access["vpn"]

  description = each.value
  type        = "ingress"
  from_port   = 0
  protocol    = "all"
  to_port     = 65535

  cidr_blocks       = [each.key]
  security_group_id = aws_security_group.app.id
}
