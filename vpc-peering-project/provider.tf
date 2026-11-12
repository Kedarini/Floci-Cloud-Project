terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  required_version = ">= 1.17.0"
}

provider "aws" {
  region     = var.primary
  alias      = "primary"
  access_key = "test"
  secret_key = "test"

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  # Endpoints required to work seamlessly with Floci
  endpoints {
    ec2        = "http://localhost:4566"
    s3         = "http://localhost:4566"
    cloudfront = "http://localhost:4566"
  }
}

provider "aws" {
  region     = var.secondary
  alias      = "secondary"
  access_key = "test"
  secret_key = "test"

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  # Endpoints required to work seamlessly with Floci
  endpoints {
    ec2        = "http://localhost:4566"
    s3         = "http://localhost:4566"
    cloudfront = "http://localhost:4566"
  }
}
