# Fetch the secret version containing the Aurora serverless password from AWS Secrets Manager
data "aws_secretsmanager_secret_version" "serverless_creds" {
  secret_id = var.aurora_serverless_password_secret_id
}

# Decode the secret string and store the RDS password in a local variable

locals {
  rds_password = jsondecode(
    data.aws_secretsmanager_secret_version.serverless_creds.secret_string
  )
}

# Define the Aurora RDS cluster resource
resource "aws_rds_cluster" "aurora_cluster" {

    cluster_identifier            = "${var.environment_name}-aurora-cluster"
    database_name                 = var.database_name
    engine                        = var.engine
    engine_mode                   = var.engine_mode
    engine_version                = var.engine_version
    master_username               = "${var.rds_master_username}"
    master_password               = local.rds_password.password
    backup_retention_period       = var.backup_retention_period
    preferred_backup_window       = "02:00-03:00"
    preferred_maintenance_window  = "wed:03:00-wed:04:00"
    db_subnet_group_name          = "${aws_db_subnet_group.aurora_subnet_group.name}"
    final_snapshot_identifier     = "${var.environment_name}-aurora-cluster"
    # Serverless configuration
    serverlessv2_scaling_configuration {
    max_capacity = var.rds_max_capacity
    min_capacity = var.rds_min_capacity
    }
    # VPC and security group settings
    vpc_security_group_ids = ["${aws_security_group.aurora-serverless_sg.id}"]

    # Tags for identification and organization
    tags = {
        Name         = "${var.environment_name}-Aurora-DB-Cluster"
        VPC          = "${var.environment_name}"
        ManagedBy    = "terraform"
        Environment  = "${var.environment_name}"
    }

    lifecycle {
        create_before_destroy = true
    }

}
# Define the Aurora RDS cluster instance resource
resource "aws_rds_cluster_instance" "aurora_cluster_instance" {
    # Create an instance for each private subnet
    count                 = length(aws_subnet.private_subnet.*.id)
    engine_version        = aws_rds_cluster.aurora_cluster.engine_version
    engine                = aws_rds_cluster.aurora_cluster.engine

    identifier            = "${var.environment_name}-aurora-instance-${count.index}"
    cluster_identifier    = "${aws_rds_cluster.aurora_cluster.id}"
    instance_class        = var.instance_class
    db_subnet_group_name  = "${aws_db_subnet_group.aurora_subnet_group.name}"
    publicly_accessible   = var.publicly_accessible

    tags = {
        Name         = "${var.environment_name}-Aurora-DB-Instance-${count.index}"
        VPC          = "${var.environment_name}"
        ManagedBy    = "terraform"
        Environment  = "${var.environment_name}"
    }

    lifecycle {
        create_before_destroy = true
    }

}
# Define the Aurora RDS cluster subnet group resource
resource "aws_db_subnet_group" "aurora_subnet_group" {

    name          = "${var.environment_name}-aurora-db-subnet-group"
    description   = "Allowed subnets for Aurora DB cluster instances"
    subnet_ids    = aws_subnet.private_subnet.*.id  

    tags = {
        Name         = "${var.environment_name}-Aurora-DB-Subnet-Group"
        VPC          = "${var.environment_name}"
        ManagedBy    = "terraform"
        Environment  = "${var.environment_name}"
    }

}
