module "node-infra" {
  source = "../module"

  cidr_block              = var.cidr_block
  enable_dns_hostnames    = var.enable_dns_hostnames
  enable_dns_support      = var.enable_dns_support
  map_public_ip_on_launch = var.map_public_ip_on_launch

  name_prefix = var.name_prefix
  aws_region  = var.aws_region
  az_count    = var.az_count

  ecr_name         = var.ecr_name
  environment_name = var.environment_name
  ecr_force_delete = var.ecr_force_delete

  iam_role_name    = var.iam_role_name
  eks_cluster_name = var.eks_cluster_name
  ng_role_name     = var.ng_role_name
  node_group_name  = var.node_group_name
  instance_types   = var.instance_types
  desired_capacity = var.desired_capacity
  min_capacity     = var.min_capacity
  max_capacity     = var.max_capacity


  rds_master_username                  = var.rds_master_username
  database_name                        = var.database_name
  engine                               = var.engine
  engine_mode                          = var.engine_mode
  engine_version                       = var.engine_version
  backup_retention_period              = var.backup_retention_period
  rds_max_capacity                     = var.rds_max_capacity
  rds_min_capacity                     = var.rds_min_capacity
  instance_class                       = var.instance_class
  publicly_accessible                  = var.publicly_accessible
  aurora_serverless_password_secret_id = var.aurora_serverless_password_secret_id
}