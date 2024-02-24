output "vpc" {
  value       = aws_vpc.vpc_dev.instance_tenancy
  description = "testing output"
}
