resource "aws_cloudwatch_log_group" "opensearch" {
  name = "${var.domain_name}"
}

resource "aws_cloudwatch_log_resource_policy" "opensearch" {
  policy_name = "opensearch-logs"

  policy_document = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "es.amazonaws.com"
      },
      "Action": [
        "logs:PutLogEvents",
        "logs:PutLogEventsBatch",
        "logs:CreateLogStream"
      ],
      "Resource": "arn:aws:logs:*"
    }
  ]
}
CONFIG
}



