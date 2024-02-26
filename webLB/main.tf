/*
web server creation through autoscalling group
traffic through elastic lb
FW rule to acces ELB from iutside, instances accessible only for ELB

to do:
remove public IPs from instances
*/
provider "aws" {
  region = "us-east-2"
  default_tags {
    tags = {
      Owner     = "terra-test"
      ManagedBy = "Terraform"
    }
  }
}

data "aws_region" "region_data" {}
data "aws_availability_zones" "az_zones" {}
data "aws_ami" "ami_ubuntu_22_04_latest" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_security_group" "elb_web_sg" {
  name = "elb_web_sg"
  dynamic "ingress" {
    for_each = ["80", "443"]
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

resource "aws_security_group" "ec2_web_sg" {
  name        = "ec2_web_sg"
  description = "allow access for ELB"
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.elb_web_sg.id] #allow traffic to instances from ELB only
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "web_lc" {
  name_prefix     = "LC web - "
  instance_type   = "t2.micro"
  image_id        = data.aws_ami.ami_ubuntu_22_04_latest.id
  security_groups = [aws_security_group.ec2_web_sg.id]
  user_data       = file("apache.sh")

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg_web" {
  name                 = "ASG - ${aws_launch_configuration.web_lc.name}" #if name of launch configuration changes, ASG will be replaced. We created a dependency.
  launch_configuration = aws_launch_configuration.web_lc.name
  min_size             = 2
  max_size             = 2
  health_check_type    = "ELB"
  load_balancers       = [aws_elb.web-elb.name]
  min_elb_capacity     = 2
  vpc_zone_identifier  = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]

  #tags for EC2 instances, that are created for ASG
  dynamic "tag" {
    for_each = {
      Name      = "webserver for ASG"
      timestamp = timestamp()
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elb" "web-elb" {
  name               = "web-elb"
  availability_zones = [data.aws_availability_zones.az_zones.names[0], data.aws_availability_zones.az_zones.names[1]]
  security_groups    = [aws_security_group.elb_web_sg.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 10
  }

  tags = {
    Name = "web-test-elb"
  }
}

# для ВМок за балансировщиком публичные IP не нужны, поэтому лучше их не назначать. А назначение настраивается в subnet, в этом ресурсе не получится такое настроить, поэтому, возможно, лучше сделать новые сабнеты и там настроить
resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.az_zones.names[0]
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = data.aws_availability_zones.az_zones.names[1]
}
