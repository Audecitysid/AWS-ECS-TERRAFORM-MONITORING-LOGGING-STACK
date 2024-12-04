resource "aws_launch_template" "bastion" {
  name        = "${local.name_prefix}-bastion"
  description = "${local.name_prefix}-bastion"

  image_id      = var.image_id
  ebs_optimized = true
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [var.sg.id]

  disable_api_termination              = false
  instance_initiated_shutdown_behavior = "terminate"

  iam_instance_profile {
    name = aws_iam_instance_profile.bastion.name
  }

  monitoring {
    enabled = false
  }

  dynamic "tag_specifications" {
    for_each = ["instance", "volume"]

    content {
      resource_type = tag_specifications.value

      tags = merge(local.common_tags, {
        Name = "${local.name_prefix}-bastion"
      })
    }
  }

  tags = local.common_tags

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = var.volume_size
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  user_data = data.template_cloudinit_config.bastion.rendered

  lifecycle {
    create_before_destroy = true
  }
}
