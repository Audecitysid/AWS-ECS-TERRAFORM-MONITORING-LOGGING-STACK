
# Output ALB ARN
output "alb_arn" {
  value       = module.ecs-cluster.alb_arn
  description = "The ARN of the ALB"
}

output "sg_alb_id" {
  value = module.ecs-cluster.sg_alb_id
}
