variable "project_name" {
  type    = string
  default = "Project ALPHA source"
}

variable "bucket_name" {
  type    = string
  default = "exampleBUCKET NaMe"
}

variable "default_tags" {
  type = map(string)
  default = {
    company    = "TechCorp"
    managed_by = "terraform"
  }
}

variable "enviroment_tags" {
  type = map(string)
  default = {
    environment = "production"
    cost_center = "cc-123"
  }
}

variable "allowed_ports" {
  type        = string
  description = "Comma-separated list of allowed ports"
  default     = "80,443,8080,3306"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"

  validation {
    condition     = length(var.instance_type) >= 2 && length(var.instance_type) <= 20
    error_message = "instance_type must be between 2 and 20 characters"
  }

  validation {
    condition     = can(regex("^t[2-3]\\.", var.instance_type))
    error_message = "Instance type must start with t2 or t3"
  }
}
