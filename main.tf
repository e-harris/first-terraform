provider "aws" {
  region = "eu-west-1"
}

# create a VPC

# resource "aws_vpc" "app_vpc"{
#  cidr_block = 10.0.0.0/16
#  tags = {
#    Name = "elliot-eng54-app_vpc"
#  }
# }

# use the devopsstudentsubnet
    #   vpc-07e47e9d90d2076da
# create new subnet
# move our instance into said subnet
resource "aws_subnet" "app_subnet_elliot" {
  vpc_id = "vpc-07e47e9d90d2076da"
  cidr_block = "172.31.44.0/24"
  availability_zone = "eu-west-1a"
  tags = {
    Name = "elliot-eng54-sunet-public"
  }
}



# Launching a resource

resource "aws_instance" "app_instance" {
  ami = "ami-040bb941f8d94b312"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.app_subnet_elliot.id}"
  vpc_security_group_ids = [aws_security_group.elliot_eng54_terraform.id]
  tags = {
    Name = "elliot-eng54-app"
  }
}

resource "aws_security_group" "elliot_eng54_terraform" {
  name        = "elliot-eng54-terraform"
  description = "Allow TLS inbound traffic"
  vpc_id      = "vpc-07e47e9d90d2076da"

  ingress {
    description = "Allows access on port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "elliot-eng54-app-security"
  }
}


# route table
# NACL
# Security groups
# More subnets
