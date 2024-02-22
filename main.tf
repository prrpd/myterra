provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "vm1" {
  count         = 2
  ami           = var.ami
  instance_type = "t2.micro"
}


