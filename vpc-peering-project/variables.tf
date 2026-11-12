variable "primary" {
  type    = string
  default = "us-east-1"
}

variable "secondary" {
  type    = string
  default = "us-west-1"
}

variable "primary_vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "secondary_vpc_cidr" {
  type    = string
  default = "10.1.0.0/16"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}


variable "primary_key_name" {
  description = "Name of the SSH key pair for Primary VPC instance (us-east-1)"
  type        = string
  default     = ""
}

variable "secondary_key_name" {
  description = "Name of the SSH key pair for Secondary VPC instance (us-west-2)"
  type        = string
  default     = ""
}
