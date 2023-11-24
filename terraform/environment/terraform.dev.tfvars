cidr_block              = "10.0.0.0/16"
enable_dns_hostnames    = true
enable_dns_support      = true
map_public_ip_on_launch = true

name_prefix = "dev-vpc"
aws_region  = "us-west-2"
az_count    = 2

ecr_name         = "dev-ecr"
environment_name = "development"
ecr_force_delete = true

iam_role_name    = "dev-eks-cluster-demo"
eks_cluster_name = "dev-eks"
ng_role_name     = "dev-eks-node-group-nodes"
node_group_name  = "dev-private-nodes"
instance_types   = ["t3.small"]
desired_capacity = 1
max_capacity     = 3
min_capacity     = 1

rds_master_username                  = "dev-master-username"
database_name                        = "dev-mydb"
engine                               = "aurora-postgresql"
engine_mode                          = "provisioned"
engine_version                       = "15.3"
backup_retention_period              = 14
rds_max_capacity                     = 1.0
rds_min_capacity                     = 0.5
instance_class                       = "db.serverless"
publicly_accessible                  = true
aurora_serverless_password_secret_id = "dev-nodeapp_aurora_serverless_password"
