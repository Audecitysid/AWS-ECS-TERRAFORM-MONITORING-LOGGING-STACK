resource "aws_iam_role" "ec2_ecs_instance_role" {
  name               = "ec2-ecs-instance-role"
  path = "/"
  assume_role_policy = data.aws_iam_policy_document.ec2_ecs_instance_policy.json
}

data "aws_iam_policy_document" "ec2_ecs_instance_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "ec2_ecs_describe_policy" {
  name = "ec2-ecs-describe-policy"
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
  role = aws_iam_role.ec2_ecs_instance_role.name
  policy_arn = aws_iam_policy.ec2_ecs_describe_policy.arn
}

resource "aws_iam_role_policy_attachment" "ec2_ecs_instance_role_attachment" {
  role       = aws_iam_role.ec2_ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ec2_ecs_instance_profile" {
  name = "ecs-instance-profile"
  path = "/"
  role =  aws_iam_role.ec2_ecs_instance_role.id
}