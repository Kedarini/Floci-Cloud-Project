output "vpc_id" {
  value = aws_vpc.main.id
}

output "ec2_id" {
  value = aws_instance.example.id
}
