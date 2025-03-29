module "networking" {
  source = "./modules/networking/"
  project_name = var.project_name
  aws_region = var.aws_region
}