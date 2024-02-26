output "sg_name" {
  value = aws_security_group.sg_web.name
}

output "sg_id" {
  value = aws_security_group.sg_web.id
}

output "public_ip" {
  value = aws_instance.web1.public_ip
}
