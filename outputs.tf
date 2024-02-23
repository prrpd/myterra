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

output "publicIP" {
  value = aws_instance.vm1[*].public_ip
}

output "SGID" {
  value = aws_security_group.webserversg.id
}
