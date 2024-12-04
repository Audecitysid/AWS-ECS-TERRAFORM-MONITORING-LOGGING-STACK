resource "aws_iam_service_linked_role" "es" {
  aws_service_name = "es.amazonaws.com"
}

resource "aws_opensearch_domain" "es" {
  domain_name           = var.domain_name
  engine_version = var.versionES

  encrypt_at_rest {
    enabled = true
  }

  cluster_config {
    instance_type          = var.instance_type
    instance_count         = var.instance_count
    zone_awareness_enabled = true

    zone_awareness_config {
      availability_zone_count = var.az_count
    }
  }

  vpc_options {
    subnet_ids         = slice(var.subnets[*].id, 0, var.az_count)
    security_group_ids = var.sg[*].id
  }

  ebs_options {
    ebs_enabled = true
    volume_size = var.volume_size
    volume_type = "gp2"
  }

  snapshot_options {
    automated_snapshot_start_hour = var.automated_snapshot_start_hour
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch.arn
    enabled  = true
    log_type = "ES_APPLICATION_LOGS"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch.arn
    enabled  = true
    log_type = "SEARCH_SLOW_LOGS"
  }


  node_to_node_encryption {
    enabled = true
  }

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }


  access_policies = <<CONFIG
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow",
            "Resource": "arn:aws:es:${var.region}:${var.account_id}:domain/${var.domain_name}/*"
        }
    ]
}
CONFIG

  advanced_security_options {
    enabled = false
  }


  depends_on = [aws_iam_service_linked_role.es]

  tags = {
    Domain = var.domain_name
  }
}
