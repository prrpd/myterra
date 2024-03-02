/*
creating 2 vpcs, configuring peering between them
also creating subnets, route eables, internet gateway.
Internet gateway is needed only for ssh connection through 
AWS console, it requires access from public internet, alsom this 
is why EC2 instances have public IPs. If I configured local ssh connection,
no public IPs, IGs and security rules to access from internet required.

uses provisioner "local-exec" {
    command = "sleep 10; ping -4c5 ${aws_instance.vm2.private_ip}"
  } to ping other instance

to do:

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

/*
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
*/

/*
instead of creating a new route table with aws_route_table,
I'm taking into control using aws_default_route_table
default route table which is automatially created with creation of a vpc
*/
resource "aws_default_route_table" "route1" {
  default_route_table_id = aws_vpc.vpc1.default_route_table_id

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

# resource "aws_route_table_association" "a" {
#   subnet_id      = aws_subnet.subnet1.id
#   route_table_id = aws_route_table.route1.id
# }

resource "aws_vpc" "vpc2" {
  cidr_block = "10.2.0.0/16"
  tags = {
    Name = "test vpc peering"
  }
}
/*
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
*/
resource "aws_default_route_table" "route2" {
  default_route_table_id = aws_vpc.vpc2.default_route_table_id

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

# resource "aws_route_table_association" "b" {
#   subnet_id      = aws_subnet.subnet2.id
#   route_table_id = aws_route_table.route2.id
# }

resource "aws_instance" "vm1" {
  ami                    = data.aws_ami.ami_ubuntu_22_04_latest.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.sg1.id]
  provisioner "local-exec" {
    command = "hostname; sleep 30; ping -4c5 ${aws_instance.vm2.private_ip}"
  }
  tags = {
    Name = "test vpc peering"
  }
}

resource "aws_instance" "vm2" {
  ami                    = data.aws_ami.ami_ubuntu_22_04_latest.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet2.id
  vpc_security_group_ids = [aws_security_group.sg2.id]
  # provisioner "local-exec" {
  #   command = "ping -4c5 ${aws_instance.vm1.private_ip}"
  # }
  tags = {
    Name = "test vpc peering"
  }
}

resource "aws_security_group" "sg1" {
  name_prefix = "EC2_INSTANCE_CONNECT_"
  vpc_id      = aws_vpc.vpc1.id
  ingress {
    description = "Allow SSH for AWS console EC2_INSTANCE_CONNECT"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["3.16.146.0/29"]
  }
  ingress {
    description = "Allow all incoming ICMP IPv4 traffic"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.0.0/8"]
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
    description = "Allow SSH for AWS console EC2_INSTANCE_CONNECT"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["3.16.146.0/29"]
  }
  ingress {
    description = "Allow all incoming ICMP IPv4 traffic"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.0.0/8"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
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
