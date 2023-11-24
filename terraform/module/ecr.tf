# Define an AWS ECR repository resource
resource "aws_ecr_repository" "ecr" {
  name  = "${var.ecr_name}"
  force_delete = var.ecr_force_delete

  image_scanning_configuration {
    scan_on_push = true
  }

}
# Output the ECR repository URL for external use
output "ecr_repository_url" {
  value = aws_ecr_repository.ecr.repository_url
}
