output "frontend_alb_dns" {
    value = aws_lb.frontend.dns_name
}

output "backend_alb_dns" {
    value = aws_lb.backend.dns_name
}