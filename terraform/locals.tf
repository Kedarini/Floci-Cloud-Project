locals {
  bucket_name = "bucket-${var.environment}"
  vpc_name    = "vpc-${var.environment}"
  ec2_name    = "ec2-${var.environment}"
}
