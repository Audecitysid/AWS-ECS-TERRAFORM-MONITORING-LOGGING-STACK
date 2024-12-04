output "ec2_ids" {
  value = [
    for app in module.ec2 :
    app.ec2_id
  ]
}

output "ec2_private_ips" {
  value = [
    for app in module.ec2 :
    app.ec2_private_ip
  ]
}
