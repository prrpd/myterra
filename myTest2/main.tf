provider "aws" {
  region = "us-east-2"
  default_tags {
    tags = {
      Owner     = "terra-test"
      ManagedBy = "Terraform"
    }
  }
}

data "aws_vpc" "vpc_data" {
  tags = {
    Name = "dev"
  }
}
data "aws_region" "region_data" {}

resource "aws_vpc" "vpc_dev" {
  cidr_block = "10.10.1.0/24"
  tags = {
    Name   = "dev"
    Region = data.aws_region.region_data.description
  }
}

resource "aws_subnet" "subnet_dev1" {
  vpc_id     = aws_vpc.vpc_dev.id
  cidr_block = "10.10.1.0/28"
}
