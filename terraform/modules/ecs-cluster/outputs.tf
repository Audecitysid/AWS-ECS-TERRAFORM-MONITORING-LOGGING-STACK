
output "sg_alb_id" {
  value = aws_security_group.alb_sg.id
  description = "Security Group ID for the Application Load Balancer"
}
