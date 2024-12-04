## ES

//resource "aws_cloudwatch_metric_alarm" "elastisearch_cpu_usage" {
//  alarm_name  = "ct-${var.env}-elastisearch-cpu-usage"
//  namespace   = "AWS/ES"
//  metric_name = "CPUUtilization"
//
//  comparison_operator = "GreaterThanOrEqualToThreshold"
//  statistic           = "Average"
//
//  threshold          = "85"
//  period             = "60"
//  evaluation_periods = "5"
//  #alarm_actions      = [aws_sns_topic.ModentoInfraAlerts.arn]
//
//  dimensions = {
//    DomainName = var.domain_name
//    ClientId   = var.account_id
//  }
//}
//
//resource "aws_cloudwatch_metric_alarm" "elastisearch_free_space" {
//  alarm_name  = "ct-${var.env}-elastisearch-free-space"
//  namespace   = "AWS/ES"
//  metric_name = "FreeStorageSpace"
//
//  comparison_operator = "LessThanThreshold"
//  statistic           = "Minimum"
//
//  threshold          = "5000"
//  period             = "60"
//  evaluation_periods = "5"
//
//  dimensions = {
//    DomainName = var.domain_name
//    ClientId   = var.account_id
//  }
//}
//
//resource "aws_cloudwatch_metric_alarm" "elastisearch_cluster_status" {
//  alarm_name  = "ct-${var.env}-elastisearch-cluster-status"
//  namespace   = "AWS/ES"
//  metric_name = "ClusterStatus.green"
//
//  comparison_operator = "LessThanThreshold"
//  statistic           = "Average"
//
//  threshold          = "1"
//  period             = "60"
//  evaluation_periods = "5"
//
//  dimensions = {
//    DomainName = var.domain_name
//    ClientId   = var.account_id
//  }
//}
//
//resource "aws_cloudwatch_metric_alarm" "elastisearch_cluster_nodes" {
//  alarm_name  = "ct-${var.env}-elastisearch-cluster-nodes"
//  namespace   = "AWS/ES"
//  metric_name = "Nodes"
//
//  comparison_operator = "LessThanThreshold"
//  statistic           = "Average"
//
//  threshold          = "2"
//  period             = "60"
//  evaluation_periods = "5"
//
//  treat_missing_data = "notBreaching"
//
//  dimensions = {
//    DomainName = var.domain_name
//    ClientId   = var.account_id
//  }
//}
//
//resource "aws_cloudwatch_metric_alarm" "elastisearch_cluster_memory" {
//  alarm_name  = "ct-${var.env}-elastisearch-cluster-memory"
//  namespace         = "AWS/ES"
//  metric_name       = "JVMMemoryPressure"
//  comparison_operator = "GreaterThanOrEqualToThreshold"
//  threshold           = "88"
//
//  evaluation_periods = "3"
//
//  statistic = "Maximum"
//  period    = "300"
//
//  dimensions = {
//     DomainName = var.domain_name
//     ClientId   = var.account_id
//  }
//}
