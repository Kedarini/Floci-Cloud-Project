terraform {
  
  backend "s3" {
    bucket = "tfstate"
    key = "terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    use_lockfile = true

    # Floci Configuration for Backend 
    endpoint = "http://localhost:4566"
    access_key = "test"
    secret_key = "test"
    skip_credentials_validation = true
    skip_region_validation      = true
  }
}

