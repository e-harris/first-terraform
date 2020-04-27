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
  vpc_id            = var.vpc_id
  cidr_block        = "172.31.44.0/24"
  availability_zone = "eu-west-1a"
  tags = {
    Name = "${var.name}subnet-public"
  }
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id          = var.vpc_id
  route {
    cidr_block    = "0.0.0.0/0"
    gateway_id    = data.aws_internet_gateway.default_gw.id
  }
  tags = {
    Name          = "${var.name}public"
  }
}

resource "aws_route_table_association" "assoc" {
  subnet_id       = aws_subnet.app_subnet_elliot.id
  route_table_id  = aws_route_table.public.id
}


# we dont need a new internet gateway, we can query our existing vpc/Infrastructure with 'data' handler
data "aws_internet_gateway" "default_gw" {
  filter{
    # on the hashicorp docs it reference AWS-API that has this filter "attachment.vpc-id"
    name    = "attachment.vpc-id"
    values  = [var.vpc_id]
  }
}

data "template_file" "app_init" {
  template = file("./templates/app_init/init.sh.tpl")
}



# Launching a resource
resource "aws_instance" "app_instance" {
  ami                           = var.ami_id
  instance_type                 = "t2.micro"
  associate_public_ip_address   = true
  subnet_id                     = "${aws_subnet.app_subnet_elliot.id}"
  vpc_security_group_ids        = [aws_security_group.elliot_eng54_terraform.id]
  tags = {
    Name                        = "${var.name}terraform-app"
  }
  key_name                      = "elliot-eng54"

  user_data = data.template_file.app_init.rendered


# One way to get Node App running on EC2 instance, but leaves terraform hanging, see templates.
  # provisioner "remote-exec" {
  #   inline  = [
  #     "cd app",
  #     "npm install",
  #     "npm start"
  #   ]
  # }
  # connection {
  #   type        = "ssh"
  #   user        = "ubuntu"
  #   private_key = file("~/.ssh/elliot-eng54.pem")
  #   host        = self.public_ip
  # }
}

# adding a security group
resource "aws_security_group" "elliot_eng54_terraform" {
  name          = "${var.name}terraform"
  description   = "Allow TLS inbound traffic"
  vpc_id        = var.vpc_id

  ingress {
    description = "Allows access on port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allows access on port 8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allows access on port 443"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allows access on port 3000"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allows access on my IP port 22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["86.174.120.138/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}app-security"
  }
}




# route table
# NACL
# Security groups
# More subnets
