provider "aws" {
  region = "eu-west-1"
}

# Moved into App_tier module

# we dont need a new internet gateway, we can query our existing vpc/Infrastructure with 'data' handler
data "aws_internet_gateway" "default_gw" {
  filter{
    # on the hashicorp docs it reference AWS-API that has this filter "attachment.vpc-id"
    name    = "attachment.vpc-id"
    values  = [var.vpc_id]
  }
}

module "app" {
  source      = "./modules/app_tier"
  vpc_id      = var.vpc_id
  name        = var.name
  ami_id      = var.ami_id
  gateway_id_var  = data.aws_internet_gateway.default_gw.id
}
