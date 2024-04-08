output "ec2_instance_connect" {
  value       = data.aws_ip_ranges.ec2_instance_connect
  description = "testing output"
}

# output "vpc_cidr" {
#   value       = aws_vpc.vpc_dev.cidr_block
#   description = "testing output"
# }

# output "subnet_id" {
#   value       = aws_subnet.subnet_dev1.id
#   description = "testing output"
# }
