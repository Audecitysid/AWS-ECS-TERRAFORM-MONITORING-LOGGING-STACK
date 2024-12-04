resource "aws_cloudwatch_log_group" "ec2-es-log-group" {
  name              = "ec2-ecs-es"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_stream" "ec2-es-log-stream" {
  name           = "ec2-es-log-stream"
  log_group_name = aws_cloudwatch_log_group.ec2-es-log-group.name
}