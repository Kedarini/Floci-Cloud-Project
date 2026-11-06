variable "environment" {
  default = "dev"
  type    = string
}

variable "aws_region" {
  default = "us-east-1"
  type    = string
}

locals {
  bucket_name = "bucket-${var.environment}"
  vpc_name    = "vpc-${var.environment}"
  ec2_name    = "ec2-${var.environment}"
}
