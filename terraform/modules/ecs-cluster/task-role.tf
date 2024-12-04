resource "aws_iam_role" "ecs_task_role" {
  name               = "ecs-task-role"
  path = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_policy.json
}

data "aws_iam_policy_document" "ecs_task_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "ec2_es_plugin_describe_policy" {
  name = "ec2-es-plugin-describe-policy"
  policy = <<EOF
{
  "Statement": [
    {
      "Action": [
        "ec2:DescribeInstances"
      ],
      "Effect": "Allow",
      "Resource": [
        "*"
      ]
    }
  ],
  "Version": "2012-10-17"
}
EOF
}

resource "aws_iam_role_policy_attachment" "ec2_es_describe_policy_attachment" {
  role = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ec2_es_plugin_describe_policy.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_s3_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}