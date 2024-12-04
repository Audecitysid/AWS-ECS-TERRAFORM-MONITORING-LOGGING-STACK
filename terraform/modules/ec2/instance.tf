resource "aws_instance" "app" {
  ami           = var.image_id
  ebs_optimized = true
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids      = [var.sg.id]
  availability_zone           = var.az
  associate_public_ip_address = false
  private_ip                  = var.private_ip
  subnet_id = element([
    for s in var.subnets : s.id if s.availability_zone == var.az
  ], 0)

  disable_api_termination              = false
  instance_initiated_shutdown_behavior = "stop"

  iam_instance_profile = aws_iam_instance_profile.app.name

  monitoring = false

  user_data = data.template_cloudinit_config.ec2.rendered

  root_block_device {
    volume_type = "gp3"
    volume_size = var.volume_size
    encrypted   = true
  }

  tags = merge(local.common_tags, {
    Name = format("%s-%s", local.name_prefix, var.name)
  })
}
