
# Aurora serverless security group

resource "aws_security_group" "aurora-serverless_sg" {
  name   = "${var.name_prefix}-aurora-serverless-sg"
  vpc_id = "${aws_vpc.main_network.id}"

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}