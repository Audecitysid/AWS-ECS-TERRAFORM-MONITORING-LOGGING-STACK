### INSTANCE POLICY

data "aws_iam_policy_document" "common_instance_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "bastion_instance" {
  name               = "${local.name_prefix}-bastion-instance"
  assume_role_policy = data.aws_iam_policy_document.common_instance_assume.json

  tags = local.common_tags
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${local.name_prefix}-bastion"
  role = aws_iam_role.bastion_instance.name
}