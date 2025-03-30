# FE ALB SG
resource "aws_security_group" "alb" {
  name   = "${var.project_name}-alb-sg"
  vpc_id = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# FE SG 
resource "aws_security_group" "frontend" {
  name   = "${var.project_name}-frontend-sg"
  vpc_id = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = var.frontend_port
    to_port         = var.frontend_port
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}



# BE SG 
resource "aws_security_group" "backend" {
  name   = "${var.project_name}-backend-sg"
  vpc_id = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = var.backend_port
    to_port         = var.backend_port
    security_groups = [aws_security_group.frontend.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

