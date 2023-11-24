# Define an AWS IAM role for EKS
resource "aws_iam_role" "demo" {
  name = var.iam_role_name

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# Attach the AmazonEKSClusterPolicy to the IAM role
resource "aws_iam_role_policy_attachment" "demo-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.demo.name
}

# Define an AWS EKS cluster
resource "aws_eks_cluster" "demo" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.demo.arn

# VPC configuration for the EKS cluster
  vpc_config {
    subnet_ids = [
      aws_subnet.public_subnet[0].id,
      aws_subnet.public_subnet[1].id,
      aws_subnet.private_subnet[0].id,
      aws_subnet.private_subnet[1].id
    ]
  }

  depends_on = [aws_iam_role_policy_attachment.demo-AmazonEKSClusterPolicy]
}
