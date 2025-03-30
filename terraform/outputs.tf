output "frontend_url" {
    value = "http://${module.ecs.frontend_alb_dns}"
}

output "backend_url" {
    value = "http://${module.ecs.backend_alb_dns}:${var.backend_port}"
}