output "frontend_sg_id" {
    value = aws_security_group.frontend.id
  
}

output "backend_sg_id" {
    value = aws_security_group.backend.id
  
}

output "alb_sg_id" {
    value = aws_security_group.alb.id
  
}