variable "environment" {
  default = "dev"
  type    = string
}

variable "aws_region" {
  default = ["us-east-1", "eu-central-1"]
  type    = set(string)
}

variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 1
}

variable "enable_monitoring" {
  type    = bool
  default = true
}

variable "associate_public_ip" {
  type    = bool
  default = false
}

variable "instance_tags" {
  type = map(string)
  default = {
    "Environment" = "Dev"
    "Project"     = "Floci-Cloud"
    "Owner"       = "DevOps"
  }
}

variable "allowed_cidr_blocks" {
  type    = list(string)
  default = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

variable "network_config" {
  type    = tuple([string, string, number])
  default = ["10.0.0.0/16", "10.0.1.0/24", 80]
}

variable "server_config" {
  type = object({
    name           = string
    instance_type  = string
    monitoring     = bool
    storage_gb     = number
    backup_enabled = bool
  })
  default = {
    name           = "Floci-Cloud"
    instance_type  = "t2.micro"
    monitoring     = true
    storage_gb     = 20
    backup_enabled = false
  }
}

variable "bucket_names" {
  type    = set(string)
  default = ["bucket-1", "bucket-2", "bucket-3", "bucket-4", "bucket-5"]
}
