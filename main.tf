provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "vm1" {
  count                  = var.instanceCount
  ami                    = var.ami
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.webserversg.id]
  user_data              = file("apache.sh")
}

resource "aws_security_group" "webserversg" {
  dynamic "ingress" {
    for_each = ["80", "443", "8080"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


