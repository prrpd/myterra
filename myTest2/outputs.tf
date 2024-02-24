output "instance_arn" {
  value       = aws_instance.vm1.arn
  description = "testing output"
}

output "instance_id" {
  value = aws_instance.vm1.id
}

output "private_ip" {
  value = aws_instance.vm1.private_ip
}

output "public_ip" {
  value = aws_instance.vm1.public_ip
}

output "security_group_id" {
  value = aws_security_group.webserversg.id
}
