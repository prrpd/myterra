output "dns_name_elb" {
  value = aws_elb.web-elb.dns_name
}

output "sg_name" {
  value = aws_security_group.sg_web.name
}

output "sg_id" {
  value = aws_security_group.sg_web.id
}

