variable "cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "172.17.0.0/16"
}

variable "enable_dns_hostnames" {
  description = "A boolean flag to enable/disable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "A boolean flag to enable/disable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "map_public_ip_on_launch" {
  description = "A boolean flag to map public IPs on launch for instances in the VPC"
  type        = bool
  default     = true
}

variable "name_prefix" {
  description = "A prefix to be added to names of resources created in the VPC"
  type        = string
  default     = "development-vpc"
}

variable "aws_region" {
  description = "The AWS region where the VPC and associated resources will be created"
  type        = string
  default     = "us-west-2"
}

variable "az_count" {
  description = "The number of availability zones to use for the VPC"
  type        = number
  default     = "2"
}


variable "ecr_name" {
  description = "A Docker image-compatible name for the service"
  default     = "development-ecr"
  type        = string
}

variable "environment_name" {
  description = "The name of the environment"
  type        = string
  default     = "development"
}

variable "ecr_force_delete" {
  description = "Forces deletion of Docker images before resource is destroyed"
  default     = true
  type        = bool
}


variable "rds_master_username" {
  description = "The ID's of the VPC subnets that the RDS cluster instances will be created in"
  default     = "mydb"
}

variable "rds_master_password" {
  description = "The ID's of the VPC subnets that the RDS cluster instances will be created in"
  default     = "must_be_eight_characters123456"
}

variable "iam_role_name" {
  description = "The name of the IAM role for the EKS cluster"
  type        = string
  default     = "eks-cluster-demo"
}

variable "eks_cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "development-eks"
}

variable "ng_role_name" {
  description = "The name of the IAM role for the EKS node group"
  type        = string
  default     = "eks-node-group-nodes"
}

variable "node_group_name" {
  description = "The name of the EKS node group"
  type        = string
  default     = "private-nodes"
}

variable "instance_types" {
  description = "List of EC2 instance types for the node group"
  type        = list(string)
  default     = ["t3.small"]
}

variable "desired_capacity" {
  description = "Desired number of nodes in the node group"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum number of nodes in the node group"
  type        = number
  default     = 3
}

variable "min_capacity" {
  description = "Minimum number of nodes in the node group"
  type        = number
  default     = 1
}

variable "database_name" {
  description = "Name of the Aurora RDS database"
  type        = string
  default     = "mydb"
}

variable "engine" {
  description = "Database engine for the Aurora RDS cluster"
  type        = string
  default     = "aurora-postgresql"
}

variable "engine_mode" {
  description = "Engine mode for the Aurora RDS cluster"
  type        = string
  default     = "provisioned"
}

variable "engine_version" {
  description = "Engine version for the Aurora RDS cluster"
  type        = string
  default     = "15.3"
}

variable "backup_retention_period" {
  description = "Number of days to retain automated backups"
  type        = number
  default     = 14
}


variable "rds_max_capacity" {
  description = "Maximum capacity for the serverless configuration"
  type        = number
  default     = 1.0
}

variable "rds_min_capacity" {
  description = "Minimum capacity for the serverless configuration"
  type        = number
  default     = 0.5
}

variable "instance_class" {
  description = "Instance class for the Aurora RDS cluster instance"
  type        = string
  default     = "db.serverless"
}

variable "publicly_accessible" {
  description = "Whether the Aurora RDS cluster instance is publicly accessible"
  type        = bool
  default     = true
}

variable "aurora_serverless_password_secret_id" {
  description = "Secret ID for the Aurora Serverless password in AWS Secrets Manager"
  type        = string
  default     = "nodeapp_aurora_serverless_password"
}