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
      timestamp = timestamp()
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
/*
resource "aws_vpc" "vpc1" {
  cidr_block = ["10.10.0.0/16"]

}

resource "aws_vpc" "vpc2" {
  cidr_block = ["10.11.0.0/16"]

}

resource "aws_instance" "vm1" {
  ami           = data.aws_ami.ami_ubuntu_22_04_latest.id
  instance_type = "t2.micro"
  
}

*/

resource "aws_vpc_peering_connection" "foo" {
  peer_vpc_id = aws_vpc.vpc1.id #Accepter 
  vpc_id      = aws_vpc.vpc2.id #requester
  auto_accept = true
}

resource "aws_vpc" "vpc1" {
  cidr_block = "10.1.0.0/16"
}

resource "aws_vpc" "vpc2" {
  cidr_block = "10.2.0.0/16"
}
