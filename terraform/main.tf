resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "AWS-VPC-Main"
  }
}

resource "aws_s3_bucket" "first_bucket" {
  bucket = "bucket-dev"

  tags = {
    Name = "My bucket"
    Environment = "Dev"
  }
}
