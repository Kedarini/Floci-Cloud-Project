terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  required_version = ">= 1.0"
}

provider "aws" {
  region = "us-east-1"

  # Configuration for Floci
  access_key = "test"
  secret_key = "test"

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  # Every aws service need to be declared here to http://localhost:4566
  endpoints {
    ec2         = "http://localhost:4566"
    s3          = "http://localhost:4566"
    autoscaling = "http://localhost:4566"
    dynamodb    = "http://localhost:4566"
  }
}


