resource "aws_security_group" "es" {
  description = "Elasticsearch"
  name        = "Elasticsearch"
  vpc_id      = aws_vpc.main.id

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-elasticsearch"
  })
}

### EGRESS

resource "aws_security_group_rule" "es_egress" {
  description = "ElasticSearch Egress"
  type        = "egress"
  from_port   = 0
  to_port     = 65535
  protocol    = "all"

  cidr_blocks       = [aws_vpc.main.cidr_block]
  security_group_id = aws_security_group.es.id
}

### ICMP

resource "aws_security_group_rule" "es_icmp" {
  description = "ElasticSearch ICMP"
  type        = "ingress"
  from_port   = -1
  to_port     = -1
  protocol    = "icmp"

  cidr_blocks       = [aws_vpc.main.cidr_block]
  security_group_id = aws_security_group.es.id
}

### FROM MANAGEMENT

resource "aws_security_group_rule" "es_management" {
  description = "From Management"
  type        = "ingress"
  from_port   = 0
  to_port     = 65535
  protocol    = "tcp"

  security_group_id        = aws_security_group.es.id
  source_security_group_id = aws_security_group.management.id
}
