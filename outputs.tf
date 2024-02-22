output "arn" {
  value       = aws_instance.vm1[*].arn
  description = "testing output"
}

output "ID" {
  value = aws_instance.vm1[*].id
}

output "privateIP" {
  value = aws_instance.vm1[*].private_ip
}
