provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "vm1" {
  count         = var.instanceCount
  ami           = var.ami
  instance_type = "t2.micro"
}


