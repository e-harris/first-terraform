provider "aws" {
  region = "eu-west-1"
}


# Moved into App_tier module


# create a VPC

resource "aws_vpc" "app_vpc" {
 cidr_block = "10.0.0.0/16"
 tags = {
   Name = "${var.name}Node-Sample-App-VPC"
 }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "${var.name}IGW"
  }
}

# making our own igw
# # we dont need a new internet gateway, we can query our existing vpc/Infrastructure with 'data' handler
# data "aws_internet_gateway" "default_gw" {
#   filter{
#     # on the hashicorp docs it reference AWS-API that has this filter "attachment.vpc-id"
#     name    = "attachment.vpc-id"
#     values  = [var.vpc_id]
#   }
# }

module "app" {
  source      = "./modules/app_tier"
  vpc_id      = aws_vpc.app_vpc.id
  name        = var.name
  igw         = aws_internet_gateway.igw.id
  ami_id      = var.ami_id
  # gateway_id_var  = data.aws_internet_gateway.default_gw.id
}


module "mongodb" {
  source      = "./modules/mongodb_tier"
  vpc_id      = aws_vpc.app_vpc.id
  name        = var.name
}


# route table
# NACL
# Security groups
# More subnets
