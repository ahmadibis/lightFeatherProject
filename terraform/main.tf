module "networking" {
  source       = "./modules/networking/"
  project_name = var.project_name
  aws_region   = var.aws_region
}


module "ecs" {
  source         = "./modules/ecs"
  project_name   = var.project_name
  aws_region     = var.aws_region
  vpc_id         = module.networking.vpc_id
  private        = module.networking.private_subnets
  public         = module.networking.public_subnets
  frontend_sg_id = module.security.frontend_sg_id
  backend_sg_id  = module.security.backend_sg_id
  alb_sg_id      = module.security.alb_sg_id
  frontend_image = var.frontend_image
  backend_image  = var.backend_image
  frontend_port  = var.frontend_port
  backend_port   = var.backend_port
}


module "security" {
  source        = "./modules/security"
  aws_region    = var.aws_region
  project_name  = var.project_name
  vpc_id        = module.networking.vpc_id
  frontend_port = var.frontend_port
  backend_port  = var.backend_port
}