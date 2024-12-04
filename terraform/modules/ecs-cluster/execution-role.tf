resource "aws_iam_role" "ec2_ecs_execution_role" {
  name               = "ec2-ecs-execution-role"
  path = "/"
  assume_role_policy = data.aws_iam_policy_document.ec2_ecs_execution_policy.json
}

data "aws_iam_policy_document" "ec2_ecs_execution_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ec2_ecs_execution_role_attachment" {
  role       = aws_iam_role.ec2_ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}