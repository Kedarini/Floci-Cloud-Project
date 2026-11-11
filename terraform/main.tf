locals {
  formatted_project_name = lower(replace(var.project_name, " ", "-"))
  new_tag                = merge(var.default_tags, var.enviroment_tags)
  formatted_bucket_name  = replace(substr(lower(var.bucket_name), 0, 63), " ", "")
  port_list              = split(",", var.allowed_ports)

  sg_rules = [for port in local.port_list : {
    name        = "port-${port}"
    port        = port
    description = "Allow traffic on port ${port}"
    }
  ]
}

# replace eg.
# "hello WORLD" --> "hello-world"


resource "aws_s3_bucket" "example" {
  bucket = local.formatted_bucket_name

  tags = local.new_tag
}
