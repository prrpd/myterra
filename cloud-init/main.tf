data "aws_ip_ranges" "ec2_instance_connect" {
  regions  = [var.region]
  services = ["ec2_instance_connect"]
}

data "aws_ami" "ami_ubuntu_22_04_latest" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

data "template_file" "user_data" {
  template = file("cloud-config.yaml")
}

resource "aws_instance" "vm1" {
  count                  = var.instanceCount
  ami                    = var.ami != "" ? var.ami : data.aws_ami.ami_ubuntu_22_04_latest.id #setting ami id value from either var or from data source - https://www.linkedin.com/pulse/datasource-default-value-terraform-variable-mohd-fawaz-akhtar
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.webserversg.id]
  user_data              = data.template_file.user_data.rendered
}

resource "aws_security_group" "webserversg" {
  ingress {
    description = "Allow SSH for AWS console EC2_INSTANCE_CONNECT"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = data.aws_ip_ranges.ec2_instance_connect.cidr_blocks
  }
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


