output "ec2-ecs_id" {
  value = aws_instance.app.id
}

output "ec2-ecs_private_ip" {
  value = aws_instance.app.private_ip
}
