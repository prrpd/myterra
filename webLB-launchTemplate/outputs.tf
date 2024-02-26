output "dns_name_elb" {
  value = aws_elb.web-elb.dns_name
}

# output "ec2_web_sg_name" {
#   value = aws_security_group.ec2_web_sg.name
# }

output "elb_web_sg_name" {
  value = aws_security_group.elb_web_sg.name
}
