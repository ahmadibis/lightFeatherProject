resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"
}

# ECS Task exec role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    Name = "${var.project_name}-execution-role"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# CW Log group for FE
resource "aws_cloudwatch_log_group" "frontend" {
  name = "/ecs/${var.project_name}-frontend"

  tags = {
    Name = "${var.project_name}-frontend-logs"
  }
}

# CW Log group for BE
resource "aws_cloudwatch_log_group" "backend" {
  name = "/ecs/${var.project_name}-backend"

  tags = {
    Name = "${var.project_name}-backend-logs"
  }
}


# FE task definition
resource "aws_ecs_task_definition" "frontend" {
  family                   = "${var.project_name}-frontend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name      = "frontend"
    image     = var.frontend_image
    essential = true

    portMappings = [{
      containerPort = var.frontend_port
      hostPost      = var.frontend_port
    }]

    environment = [
      {
        name  = "BACKEND_URL"
        value = "http://${aws_lb.backend.dns_name}:${var.backend_port}"
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.frontend.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])

  tags = {
    Name = "${var.project_name}-frontend-task"
  }
}

# BE task definition
resource "aws_ecs_task_definition" "backend" {
  family                   = "${var.project_name}-backend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name      = "frontend"
    image     = var.backend_image
    essential = true

    portMappings = [{
      containerPort = var.backend_port
      hostPost      = var.backend_port
    }]


    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.backend.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])

  tags = {
    Name = "${var.project_name}-backend-task"
  }
}


# FE Service
resource "aws_ecs_service" "frontend" {
  name            = "${var.project_name}-frontend-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.public
    security_groups  = [var.frontend_sg_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = "frontend"
    container_port   = var.frontend_port
  }

  depends_on = [aws_lb_listener.frontend]

  tags = {
    Name = "${var.project_name}-frontend-service"
  }
}


# BE Service
resource "aws_ecs_service" "backend" {
  name            = "${var.project_name}-backend-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private
    security_groups  = [var.backend_sg_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend.arn
    container_name   = "backend"
    container_port   = var.backend_port
  }

  depends_on = [aws_lb_listener.backend]

  tags = {
    Name = "${var.project_name}-backend-service"
  }
}

# Frontend ALB
resource "aws_lb" "frontend" {
  name               = "${var.project_name}-fe-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["var.alb_sg_id"]
  subnets            = var.public

  depends_on = [ var.alb_sg_id ]

  tags = {
    Name = "${var.project_name}-frontend-alb"
  }
}

# Frontend TG
resource "aws_lb_target_group" "frontend" {
  name        = "${var.project_name}-fe-tg"
  port        = var.frontend_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }


  tags = {
    Name = "${var.project_name}-frontend-tg"
  }

}


# Frontend ALB listener
resource "aws_lb_listener" "frontend" {
  load_balancer_arn = aws_lb.frontend.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}


# Backend ALB
resource "aws_lb" "backend" {
  name               = "${var.project_name}-be-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = ["var.alb_sg_id"]
  subnets            = var.private

  depends_on = [ var.alb_sg_id ]

  tags = {
    Name = "${var.project_name}-backend-alb"
  }
}

# Backend TG
resource "aws_lb_target_group" "backend" {
  name        = "${var.project_name}-be-tg"
  port        = var.backend_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }


  tags = {
    Name = "${var.project_name}-backend-tg"
  }

}


# Backend ALB listener
resource "aws_lb_listener" "backend" {
  load_balancer_arn = aws_lb.backend.arn
  port              = var.backend_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}
