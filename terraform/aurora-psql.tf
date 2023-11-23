
resource "aws_rds_cluster" "aurora_cluster" {

    cluster_identifier            = "${var.environment_name}-aurora-cluster"
    database_name                 = "mydb"
    engine                        = "aurora-postgresql"
    engine_mode                   = "provisioned"
    engine_version                = "15.3"
    master_username               = "mydb" #"${var.rds_master_username}"
    master_password               =  "${var.rds_master_password}"  #local.rds_password.password
    backup_retention_period       = 14
    preferred_backup_window       = "02:00-03:00"
    preferred_maintenance_window  = "wed:03:00-wed:04:00"
    db_subnet_group_name          = "${aws_db_subnet_group.aurora_subnet_group.name}"
    final_snapshot_identifier     = "${var.environment_name}-aurora-cluster"
    serverlessv2_scaling_configuration {
    max_capacity = 1.0
    min_capacity = 0.5
    }
    vpc_security_group_ids = ["${aws_security_group.aurora-serverless_sg.id}"]


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

resource "aws_rds_cluster_instance" "aurora_cluster_instance" {

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

########################
## Output
########################

# output "cluster_address" {
#     value = "${aws_rds_cluster.aurora_cluster.address}"
# }