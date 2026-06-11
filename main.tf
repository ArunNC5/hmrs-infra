module "networking" {
  source = "./modules/infra/networking"
}

module "compute" {
  source = "./modules/infra/compute/ECR"
}

module "IAM" {
  source = "./modules/infra/IAM"
}



module "ECS" {
  source                 = "./modules/infra/compute/ECS"
  ecs_execution_role_arn = module.IAM.hmrs_ecs_execution_role_arn
  repo_url               = module.compute.hmrs_np_image_repo_url
  vpc_id                 = module.networking.aws_vpc_id
  subnet_ids             = [module.networking.aws_subnet_pvt1a_id, module.networking.aws_subnet_pvt1b_id]
  pvt_rt_1_id            = module.networking.private_rt_1_id
}

module "RDS" {
  source = "./modules/infra/compute/RDS"
  ecs_security_group_ids = [module.ECS.hmrs_ecs_sg_id]
  db_subnet_group_ids = [module.networking.aws_subnet_pvt1a_id, module.networking.aws_subnet_pvt1b_id]
  vpc_id                = module.networking.aws_vpc_id
}