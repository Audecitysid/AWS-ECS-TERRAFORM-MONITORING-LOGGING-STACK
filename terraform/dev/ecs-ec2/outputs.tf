output "ec2-ecs_ids" {
  value = [
    for app in module.ecs-ec2 :
    app.ec2-ecs_id
  ]
}

output "ec2-ecs_private_ips" {
  value = [
    for app in module.ecs-ec2 :
    app.ec2-ecs_private_ip
  ]
}
