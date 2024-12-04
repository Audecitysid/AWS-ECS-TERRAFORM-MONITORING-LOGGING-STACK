resource "aws_ecs_cluster" "es-cluster" {
  name = "es-cluster"
}

data "template_file" "es" {
  template = file("${path.module}/templates/es.json")

  vars = {
    docker_image_url_es = var.docker_image_url_es
    region              = var.region
  }
}

resource "aws_lb" "es_alb" {
  name               = "es-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.subnets

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "es_tg" {
  name        = "es-tg"
  port        = 9200
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "9200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.es_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.es_tg.arn
  }
}

resource "aws_ecs_task_definition" "es" {
  family                = "es"
  container_definitions = data.template_file.es.rendered
  network_mode          = "awsvpc"

  volume {
    name      = "esdata"
    host_path = "/usr/share/elasticsearch/data"
  }

  volume {
    name      = "esconfig"
    host_path = "/usr/share/elasticsearch/config/elasticsearch.yml"
  }

  requires_compatibilities = ["EC2"]
  cpu                      = "1024"
  memory                   = "1024"

  execution_role_arn       = aws_iam_role.ec2_ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
}

resource "aws_ecs_service" "es-cluster" {
  name            = "es-cluster-service"
  cluster         = aws_ecs_cluster.es-cluster.id
  task_definition = aws_ecs_task_definition.es.arn
  desired_count   = 3
  launch_type     = "EC2"

  load_balancer {
    target_group_arn = aws_lb_target_group.es_tg.arn
    container_name   = "es-node"  # Ensure this matches the "name" in es.json
    container_port   = 9200       # Ensure this matches the "containerPort" in es.json
  }

  placement_constraints {
    type = "distinctInstance"
  }

  network_configuration {
    subnets         = var.subnets
    security_groups = [aws_security_group.ecs_sg.id]
  }

  depends_on = [aws_lb_listener.http]
}

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow inbound traffic to the ALB"
  vpc_id      = var.vpc_id

  # Existing rules
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP traffic"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS traffic"
  }

  # Added rules for specific services
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Custom service on port 8000"
  }

  ingress {
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Kibana service access"
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Prometheus service access"
  }

  ingress {
    from_port   = 5044
    to_port     = 5044
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Logstash Beats input"
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Grafana dashboard access"
  }

  # Default egress rule to allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
}

resource "aws_security_group" "ecs_sg" {
  name        = "ecs-sg"
  description = "Allow inbound traffic to the ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    from_port        = 9200
    to_port          = 9200
    protocol         = "tcp"
    security_groups  = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port        = 9300
    to_port          = 9300
    protocol         = "tcp"
    security_groups  = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Output the ALB DNS name
output "alb_dns_name" {
  value       = aws_lb.es_alb.dns_name
  description = "The DNS name of the ALB"
}

output "alb_arn" {
  value       = aws_lb.es_alb.arn
  description = "The ARN of the ALB"
}

output "alb_sg_id" {
  value       = aws_security_group.alb_sg.id
  description = "id of the security group"
}




