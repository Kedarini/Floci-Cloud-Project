terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  required_version = ">= 1.10.0"
}

provider "aws" {
  region = "us-east-1"

  # Configuration for Floci
  access_key = "test"
  secret_key = "test"

  skip_credentials_validation = true
  skip_metadata_api_check = true
  skip_requesting_account_id = true
  s3_use_path_style = true

  # Every aws service need to be declared here to http://localhost:4566
  endpoints {
    ec2 = "http://localhost:4566"
    s3 = "http://localhost:4566"
  }
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "AWS-VPC-Main"
  }
}

resource "aws_s3_bucket" "first_bucket" {
  bucket = "first-bucket"

  tags = {
    Name = "My bucket"
    Environment = "Dev"
  }
}
