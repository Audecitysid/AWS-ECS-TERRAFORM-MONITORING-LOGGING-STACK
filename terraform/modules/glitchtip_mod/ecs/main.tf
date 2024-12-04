resource "aws_ecs_cluster" "main" {
  name = "es-cluster"
}




/*

resource "aws_iam_role_policy" "ecs_task_execution_policy" {
  name = "ecs-task-execution-policy"
  role = aws_iam_role.ecs_task_execution_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "secretsmanager:GetSecretValue",
          "ssm:GetParameters"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:log-group:/ecs/prometheus:*"
      }
    ]
  })
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}
*/


/*
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP traffic"
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow Prometheus traffic from ALB"
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow Grafana traffic from ALB"
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow GlitchTip traffic from ALB"
  }

  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow ELK traffic"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
}

*/
#################################################### logstash ###################################################################

resource "aws_lb_target_group" "glitchtip_tg" {
  name        = "glitchtip-tg"
  port        = 8000  // Common port for Logstash when receiving Beats data
  protocol    = "HTTP"  // TCP is often used for Logstash inputs; change to HTTP if using HTTP input
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_listener" "glitchtip_http" {
  load_balancer_arn = var.alb_arn
  port              = 8000 // Default Kibana port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.glitchtip_tg.arn  // Ensure this points to the Kibana target group
  }
}

resource "aws_ecs_service" "glitchtip_service" {
  name             = "glitchtip-service"
  cluster          = aws_ecs_cluster.main.id  // Ensure this refers to the correct ECS cluster
  task_definition  = aws_ecs_task_definition.glitchtip.arn  // Ensure the Logstash task definition ARN is correct
  desired_count    = var.dcount
  launch_type      = "FARGATE"
  platform_version = "LATEST"

  network_configuration {
    subnets          = var.private_subnets  // Ensure these are the correct subnets for Kibana
    security_groups  = [var.existing_security_group]  // Ensure this security group is correctly set up for Kibana
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.glitchtip_tg.arn  // Ensure this target group is correctly set up for Kibana
    container_name   = "glitchtip"  // The container name should match the one in the task definition
    container_port   = 8000  // Default port for Kibana
  }

  depends_on = [
    aws_lb_listener.glitchtip_http
  ]
}


resource "aws_ecs_task_definition" "glitchtip" {
  family                   = "glitchtip"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = var.memory
  cpu                      = var.cpu
  execution_role_arn       = "arn:aws:iam::233067124947:role/ecs-task-execution-role"

  container_definitions = jsonencode([
    {
      name      = "glitchtip"
      image     = var.docker_image_url
      essential = true
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
        }
      ]
      environment = [
        {
          name  = "DATABASE_URL"
          value = "postgres://postgre:Broomble123@database-1.c58gaqk06m5v.us-east-1.rds.amazonaws.com:5432/postgres"
        },
        {
          name  = "SECRET_KEY"
          value = "c4NQqyBI8_-80-xlpUKRyMk7yMjgfODxGyR2ZActm00GXGUudnfvsOFeindDy-8DWhw"
        },
        {
          name  = "EMAIL_URL"
          value = "consolemail://"
        },
        {
          name  = "PORT"
          value = "8000"
        },
        {
          name  = "GLITCHTIP_DOMAIN"
          value = "https://app.glitchtip.com"
        },
        {
          name  = "DEFAULT_FROM_EMAIL"
          value = "email@glitchtip.com"
        },
        {
          name  = "CELERY_WORKER_AUTOSCALE"
          value = "1,3"
        },
        {
          name  = "CELERY_WORKER_MAX_TASKS_PER_CHILD"
          value = "10000"
        }
      ]
    },
    {
      name      = "worker"
      image     = "glitchtip/glitchtip"
      essential = false
      command   = ["./bin/run-celery-with-beat.sh"]
      environment = [
        {
          name  = "DATABASE_URL"
          value = "postgres://postgre:Broomble123@database-1.c58gaqk06m5v.us-east-1.rds.amazonaws.com:5432/postgres"
        },
        {
          name  = "SECRET_KEY"
          value = "c4NQqyBI8_-80-xlpUKRyMk7yMjgfODxGyR2ZActm00GXGUudnfvsOFeindDy-8DWhw"
        },
        {
          name  = "PORT"
          value = "8000"
        },
        {
          name  = "EMAIL_URL"
          value = "consolemail://"
        },
        {
          name  = "GLITCHTIP_DOMAIN"
          value = "https://app.glitchtip.com"
        },
        {
          name  = "DEFAULT_FROM_EMAIL"
          value = "email@glitchtip.com"
        },
        {
          name  = "CELERY_WORKER_AUTOSCALE"
          value = "1,3"
        },
        {
          name  = "CELERY_WORKER_MAX_TASKS_PER_CHILD"
          value = "10000"
        }
      ]
    }
  ])
}

resource "aws_cloudwatch_log_group" "glitchtip_logs" {
  name = "/ecs/glitchtip"
}
