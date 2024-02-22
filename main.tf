provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "vm1" {
  count         = 2
  ami           = "ami-0fb653ca2d3203ac1"
  instance_type = "t2.micro"
}

output "somearn" {
  value       = "aws_instance.vm1.arn"
  description = "testing output"
}

output "anotheroutput" {
  value = aws_instance.vm1.host_id
}
