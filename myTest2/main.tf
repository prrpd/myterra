provider "aws" {
  region = "us-east-2"
  default_tags {
    tags = {
      Owner     = "terra-test"
      ManagedBy = "Terraform"
    }
  }
}

data "aws_vpc" "vpc_data" {}
data "aws_region" "region_data" {}

resource "aws_vpc" "vpc_dev" {
  cidr_block = "10.10.1.0/24"
  tags = {
    Name   = "dev"
    Region = data.aws_region.region_data.description
  }
}
