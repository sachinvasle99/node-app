cidr_block              = "10.1.0.0/16"
enable_dns_hostnames    = true
enable_dns_support      = true
map_public_ip_on_launch = true
name_prefix             = "staging-vpc"
aws_region              = "us-west-2"
az_count                = 2

ecr_name         = "staging-ecr"
environment_name = "staging"
ecr_force_delete = true


iam_role_name    = "staging-eks-cluster-demo"
eks_cluster_name = "staging-eks"
ng_role_name     = "staging-eks-node-group-nodes"
node_group_name  = "staging-private-nodes"
instance_types   = ["t3.small"]
desired_capacity = 1
max_capacity     = 3
min_capacity     = 1

rds_master_username                  = "staging-master-username"
database_name                        = "staging-mydb"
engine                               = "aurora-postgresql"
engine_mode                          = "provisioned"
engine_version                       = "15.3"
backup_retention_period              = 14
rds_max_capacity                     = 1.0
rds_min_capacity                     = 0.5
instance_class                       = "db.serverless"
publicly_accessible                  = true
aurora_serverless_password_secret_id = "staging-nodeapp_aurora_serverless_password"