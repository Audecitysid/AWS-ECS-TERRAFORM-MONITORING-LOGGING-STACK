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

resource "aws_lb_target_group" "logstash_tg" {
  name        = "logstash-tg"
  port        = 5044  // Common port for Logstash when receiving Beats data
  protocol    = "HTTP"  // TCP is often used for Logstash inputs; change to HTTP if using HTTP input
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    protocol            = "HTTP"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 10
    interval            = 30
  }
}

resource "aws_lb_listener" "logstash_http" {
  load_balancer_arn = var.alb_arn
  port              = 5044 // Default Kibana port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.logstash_tg.arn  // Ensure this points to the Kibana target group
  }
}

resource "aws_ecs_service" "logstash_service" {
  name             = "logstash-service"
  cluster          = aws_ecs_cluster.main.id  // Ensure this refers to the correct ECS cluster
  task_definition  = aws_ecs_task_definition.logstash.arn  // Ensure the Logstash task definition ARN is correct
  desired_count    = var.dcount
  launch_type      = "FARGATE"
  platform_version = "LATEST"

  network_configuration {
    subnets          = var.private_subnets  // Ensure these are the correct subnets for Kibana
    security_groups  = [var.existing_security_group]  // Ensure this security group is correctly set up for Kibana
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.logstash_tg.arn  // Ensure this target group is correctly set up for Kibana
    container_name   = "logstash"  // The container name should match the one in the task definition
    container_port   = 5044  // Default port for Kibana
  }

  depends_on = [
    aws_lb_listener.logstash_http
  ]
}


resource "aws_ecs_task_definition" "logstash" {
  family                   = "V8log_stash"
  network_mode             = "awsvpc"
  task_role_arn            = "arn:aws:iam::233067124947:role/ecs-task-execution-role"
  execution_role_arn       = "arn:aws:iam::233067124947:role/ecsTaskExecutionRole"
  cpu                      = var.cpu
  memory                   = var.memory
  requires_compatibilities = ["EC2", "FARGATE"]

  container_definitions = jsonencode([
    {
      name               = "logstash"
      image              = var.docker_image_url
      
      cpu                = 8192
      memory             = 12288
      memoryReservation  = 10240
      essential          = true
      portMappings = [
        {
          containerPort = 5044
          hostPort      = 5044
          protocol      = "tcp"
        },
        {
          containerPort = 9600
          hostPort      = 9600
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/V8log_stash"
          "awslogs-create-group"  = "true"
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

