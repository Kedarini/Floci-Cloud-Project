resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name        = local.vpc_name
    Environment = var.environment
  }
}

resource "aws_s3_bucket" "first_bucket" {
  bucket = local.bucket_name

  tags = {
    Name        = local.bucket_name
    Environment = var.environment
  }
}

resource "aws_instance" "example" {
  ami           = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
  instance_type = "t2.micro"

  count = var.instance_count

  monitoring                  = var.enable_monitoring
  associate_public_ip_address = var.associate_public_ip

  region = tolist(var.aws_region)[0]

  tags = var.instance_tags
}

resource "aws_security_group" "floci_sg" {
  name = "${var.server_config.name}-sg"

  ingress {
    from_port   = var.network_config[2]
    to_port     = var.network_config[2]
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.instance_tags
}

resource "aws_s3_bucket" "bucket" {
  for_each = var.bucket_names
  bucket   = each.key

  tags = var.instance_tags
}
