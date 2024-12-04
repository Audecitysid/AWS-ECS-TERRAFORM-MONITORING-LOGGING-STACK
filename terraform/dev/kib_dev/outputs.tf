

output "ecs_cluster_id" {
  description = "The ID of the ECS cluster."
  value       = module.ecs.ecs_cluster_id
}

output "ecs_task_execution_role_arn" {
  description = "The ARN of the ECS task execution role."
  value       = module.ecs.ecs_task_execution_role_arn
}

