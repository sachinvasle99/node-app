variable "name_prefix" {
  default = "development-vpc"
}

variable "aws_region" {
  default = "us-west-2"
}

variable "az_count" {
  default = "2"
}


variable "ecr_name" {
  description = "A Docker image-compatible name for the service"
  default = "development-ecr"
  type        = string
}

variable "environment_name" {
    description = "The name of the environment"
    default = "development"
} 

variable "ecr_force_delete" {
  description = "Forces deletion of Docker images before resource is destroyed"
  default     = true
  type        = bool
}
variable "vpc_id" {
  description = "The ID of the VPC that the RDS cluster will be created in"
  default = null
}

variable "vpc_name" {
  description = "The name of the VPC that the RDS cluster will be created in"
  default = "development"
}

variable "vpc_rds_subnet_ids" {
  description = "The ID's of the VPC subnets that the RDS cluster instances will be created in"
  default = ["subnet-0187e0a67d4ae0eff","subnet-027fc443ab8a5490e","subnet-0aaf481dbc3af9b33"]
}

variable "vpc_rds_security_group_id" {
    description = "The ID of the security group that should be used for the RDS cluster instances"
    default = "sg-0430fc31d162997d0"
}

variable "rds_master_username" {
  description = "The ID's of the VPC subnets that the RDS cluster instances will be created in"
  default = "mydb"
}

variable "rds_master_password" {
  description = "The ID's of the VPC subnets that the RDS cluster instances will be created in"
  default = "must_be_eight_characters123456"
}

variable "iam_role_name" {
  default = "eks-cluster-demo"
}

variable "eks_cluster_name" {
  default = "development-eks"
}

variable "ng_role_name" {
  default = "eks-node-group-nodes"
}

variable "node_group_name" {
  default = "private-nodes"
}