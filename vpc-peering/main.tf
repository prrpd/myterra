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

#data --------------------------
data "aws_ami" "ami_ubuntu_22_04_latest" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}
#---------------------------------------

resource "aws_vpc_peering_connection" "foo" {
  peer_vpc_id = aws_vpc.vpc1.id #Accepter 
  vpc_id      = aws_vpc.vpc2.id #requester
  auto_accept = true
}

resource "aws_vpc" "vpc1" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "test vpc peering"
  }
}

resource "aws_route_table" "route1" {
  vpc_id = aws_vpc.vpc1.id
  route {
    cidr_block = "10.2.1.0/24"
    gateway_id = aws_vpc_peering_connection.foo.id
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig1.id
  }

  tags = {
    Name = "test vpc peering"
  }
}

resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "test vpc peering"
  }
}

resource "aws_vpc" "vpc2" {
  cidr_block = "10.2.0.0/16"
  tags = {
    Name = "test vpc peering"
  }
}

resource "aws_route_table" "route2" {
  vpc_id = aws_vpc.vpc2.id
  route {
    cidr_block = "10.1.1.0/24"
    gateway_id = aws_vpc_peering_connection.foo.id
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig2.id
  }

  tags = {
    Name = "test vpc peering"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.vpc2.id
  cidr_block              = "10.2.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "test vpc peering"
  }
}

resource "aws_instance" "vm1" {
  ami                    = data.aws_ami.ami_ubuntu_22_04_latest.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.sg1.id]
  tags = {
    Name = "test vpc peering"
  }
}

resource "aws_instance" "vm2" {
  ami                    = data.aws_ami.ami_ubuntu_22_04_latest.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet2.id
  vpc_security_group_ids = [aws_security_group.sg2.id]
  tags = {
    Name = "test vpc peering"
  }
}

resource "aws_security_group" "sg1" {
  name_prefix = "EC2_INSTANCE_CONNECT_"
  vpc_id      = aws_vpc.vpc1.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["3.16.146.0/29"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg2" {
  name_prefix = "EC2_INSTANCE_CONNECT_"
  vpc_id      = aws_vpc.vpc2.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["3.16.146.0/29"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_internet_gateway" "ig1" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name = "test vpc peering"
  }
}

resource "aws_internet_gateway" "ig2" {
  vpc_id = aws_vpc.vpc2.id
  tags = {
    Name = "test vpc peering"
  }
}
