resource "aws_ecs_cluster" "main" {
  name = "es-cluster"
}



resource "aws_iam_role" "Iamadminrole" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "admin_access" {
  role       = aws_iam_role.Iamadminrole.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}


resource "aws_iam_role_policy" "ecs_task_execution_policy1" {
  name   = "ecsTaskExecutionPolicy"
  role   = aws_iam_role.ecs_task_execution_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "ecs:UpdateService",
        "ecs:DescribeClusters",
        "ecs:DescribeTaskDefinition",
        "ecs:DescribeTasks",
        "ecs:ListTasks",
        "secretsmanager:GetSecretValue",
        "ssm:GetParameters"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}




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



#################################################### kibana ###################################################################

resource "aws_lb_target_group" "kibana_tg" {
  name        = "kibana-tg"
  port        = 5601  // Default Kibana port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/api/status"  // Typical health check path for Kibana
    port = "traffic-port"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200-299"
  }
}

resource "aws_lb_listener" "kibana_http" {
  load_balancer_arn = var.alb_arn
  port              = 5601  // Default Kibana port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kibana_tg.arn  // Ensure this points to the Kibana target group
  }
}

resource "aws_ecs_service" "kibana_service" {
  name             = "kibana-service"
  cluster          = aws_ecs_cluster.main.id  // Ensure this refers to the correct ECS cluster
  task_definition  = aws_ecs_task_definition.kibana.arn  // Ensure the Kibana task definition ARN is correct
  desired_count    = var.dcount
  launch_type      = "FARGATE"
  platform_version = "LATEST"

  network_configuration {
    subnets          = var.private_subnets  // Ensure these are the correct subnets for Kibana
    security_groups  = [var.existing_security_group]  // Ensure this security group is correctly set up for Kibana
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.kibana_tg.arn  // Ensure this target group is correctly set up for Kibana
    container_name   = "kibana"  // The container name should match the one in the task definition
    container_port   = 5601  // Default port for Kibana
  }

  depends_on = [
    aws_lb_listener.kibana_http  // This depends on should reference the Kibana listener
  ]
}

resource "aws_ecs_task_definition" "kibana" {
  family                   = "V1Kibana"
  task_role_arn            = "arn:aws:iam::233067124947:role/ecs-task-execution-role"
  execution_role_arn       = "arn:aws:iam::233067124947:role/ecsTaskExecutionRole"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2" , "FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory

  container_definitions = jsonencode([
    {
      name               = "kibana"
      image              = var.docker_image_url
      cpu                = 8192
      memory             = 12288
      memoryReservation  = 10240
      essential          = true
      portMappings = [
        {
          containerPort = 5601
          hostPort      = 5601
          protocol      = "tcp"
        },
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        },
        {
          containerPort = 443
          hostPort      = 443
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/V1Kibana",
          "awslogs-region"        = "us-east-1",
          "awslogs-stream-prefix" = "ecs",
          "awslogs-create-group"  = "true"
        }
      }
    }
  ])
}
