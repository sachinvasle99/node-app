# Fetch the secret version containing the Aurora serverless password from AWS Secrets Manager
data "aws_secretsmanager_secret_version" "serverless_creds" {
  secret_id = "nodeapp_aurora_serverless_password"
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
    database_name                 = "mydb"
    engine                        = "aurora-postgresql"
    engine_mode                   = "provisioned"
    engine_version                = "15.3"
    master_username               = "${var.rds_master_username}"
    master_password               = local.rds_password.password
    backup_retention_period       = 14
    preferred_backup_window       = "02:00-03:00"
    preferred_maintenance_window  = "wed:03:00-wed:04:00"
    db_subnet_group_name          = "${aws_db_subnet_group.aurora_subnet_group.name}"
    final_snapshot_identifier     = "${var.environment_name}-aurora-cluster"
    # Serverless configuration
    serverlessv2_scaling_configuration {
    max_capacity = 1.0
    min_capacity = 0.5
    }
    # VPC and security group settings
    vpc_security_group_ids = ["${aws_security_group.aurora-serverless_sg.id}"]

    # Tags for identification and organization
    tags = {
        Name         = "${var.environment_name}-Aurora-DB-Cluster"
        VPC          = "${var.vpc_name}"
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
    instance_class        = "db.serverless"
    db_subnet_group_name  = "${aws_db_subnet_group.aurora_subnet_group.name}"
    publicly_accessible   = true

    tags = {
        Name         = "${var.environment_name}-Aurora-DB-Instance-${count.index}"
        VPC          = "${var.vpc_name}"
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
    subnet_ids    = aws_subnet.private_subnet.*.id    #var.vpc_rds_subnet_ids

    tags = {
        Name         = "${var.environment_name}-Aurora-DB-Subnet-Group"
        VPC          = "${var.vpc_name}"
        ManagedBy    = "terraform"
        Environment  = "${var.environment_name}"
    }

}
