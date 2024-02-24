provider "aws" {
  region = "us-east-2"
  default_tags {
    tags = {
      Owner     = "terra-test"
      ManagedBy = "Terraform"
    }
  }
}

data "aws_ami" "ami_ubuntu_22_04_latest" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}
resource "aws_instance" "vm1" {
  count                  = var.instanceCount
  ami                    = var.ami != "" ? var.ami : data.aws_ami.ami_ubuntu_22_04_latest.id #setting ami id value from either var or from data source - https://www.linkedin.com/pulse/datasource-default-value-terraform-variable-mohd-fawaz-akhtar
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


