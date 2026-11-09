data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_instance" "floci_cloud" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type

  tags = merge(
    var.resource_tags,
    {
      Name = var.instance_name
      Demo = "create_before_destroy"
    }
  )

  # This ensure zero downtime during instance updates
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_s3_bucket" "critical_data" {
  bucket = "my-crtical_production_data-${var.environment}-${data.aws_region.current.region}"

  tags = merge(
    var.resource_tags,
    {
      Name       = "Critical Production Data Bucket"
      Demo       = "prevent_destroy"
      DataType   = "Critical"
      Compliance = "Required"
    }
  )

  # Prevent accidental deletion of this bucket
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "critical_data" {
  bucket = aws_s3_bucket.critical_data.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_launch_template" "app_server" {
  name_prefix   = "app-server-"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.resource_tags,
      {
        Name = "Floci Cloud from ASG"
        Demo = "ignore_changes"
      }
    )
  }
}

resource "aws_autoscaling_group" "floci_cloud" {
  name               = "app-servers-asg"
  min_size           = 1
  max_size           = 5
  desired_capacity   = 2
  health_check_type  = "EC2"
  availability_zones = data.aws_availability_zones.available.names

  launch_template {
    id      = aws_launch_template.app_server.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "Floci Server ASG"
    propagate_at_launch = true
  }

  tag {
    key                 = "Demo"
    value               = "ignore_changes"
    propagate_at_launch = false
  }


  # Useful when auto-scaling policies modify capacity
  # Terraform won't try to revert capacity changes made outisde of Terraform
  lifecycle {
    ignore_changes = [
      desired_capacity,
    ]
  }
}

resource "aws_s3_bucket" "regional_validation" {
  bucket = "validated-region-bucket-${var.environment}-${data.aws_region.current.region}"

  tags = merge(
    var.resource_tags,
    {
      Name = "Region Validated Bucket"
      Demo = "precondition"
    }
  )

  # Prevents resource creation in unauthorized regions
  lifecycle {
    precondition {
      condition     = contains(var.allowed_regions, data.aws_region.current.region)
      error_message = "ERROR: This resource can only be created in allowed regions: ${join(", ", var.allowed_regions)}. Current region: ${data.aws_region.current.region}"
    }
  }
}

resource "aws_s3_bucket" "compliance_bucket" {
  bucket = "compliance-bucket-${var.environment}-${data.aws_region.current.region}"

  tags = merge(
    var.resource_tags,
    {
      Name       = "Compliance Validated Bucket"
      Demo       = "postcondition"
      Compliance = "SOC2"
    }
  )


  # Ensures compliance with tagging policies
  lifecycle {
    postcondition {
      condition     = contains(keys(self.tags), "Compliance")
      error_message = "ERROR: Bucket mus have a 'Compliance' tag for audit purposes!"
    }

    postcondition {
      condition     = contains(keys(self.tags), "Environment")
      error_message = "ERROR: Bucket must have an 'Environment' tag!"
    }
  }
}

resource "aws_security_group" "app_sg" {
  name        = "app-security-group"
  description = "Security group for application servers"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP from anywhere"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS from anywhere"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    var.resource_tags,
    {
      Name = "App Security Group"
      Demo = "replace_triggered_by"
    }
  )
}

resource "aws_instance" "app_with_sg" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  tags = merge(
    var.resource_tags,
    {
      Name = "App Instance with Security Group"
      Demo = "replace_trigerred_by"
    }
  )

  # Ensures the istance is recreated with new security rules
  lifecycle {
    replace_triggered_by = [
      aws_security_group.app_sg.id
    ]
  }
}


resource "aws_s3_bucket" "app_buckets" {
  for_each = var.bucket_names

  bucket = "${each.value}-${var.environment}"

  tags = merge(
    var.resource_tags,
    {
      Name   = each.value
      Demo   = "for_each_with_lifecycle"
      Bucket = each.key
    }
  )

  # Useful when renaming buckets or migrating data
  lifecycle {
    create_before_destroy = true
    ignore_changes        = []
  }
}

resource "aws_dynamodb_table" "critical_app_data" {
  name         = "${var.environment}-app-data-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  attribute {
    name = "id"
    type = "S"
  }

  tags = merge(
    var.resource_tags,
    {
      Name        = "Critical Application Data"
      Demo        = "multiple_lifecycle_rules"
      DataType    = "Critical"
      Environmnet = var.environment
    }
  )

  lifecycle {
    # Prevent accidental table destroy
    prevent_destroy = true

    # Ensures zero downtime if table needs to be recreated
    create_before_destroy = true

    #Allow AWS to manage read/write capacity for auto-scaling
    ignore_changes = [
      read_capacity,
      write_capacity,
    ]

    precondition {
      condition     = contains(keys(var.resource_tags), "Environment")
      error_message = "Critical table must have Environment tag for compliance!"
    }

    postcondition {
      condition     = self.billing_mode == "PAY_PER_REQUEST" || self.billing_mode == "PROVISIONED"
      error_message = "Billing mode must be either PAY_PER_REQUEST or PROVISIONED!"
    }
  }
}
