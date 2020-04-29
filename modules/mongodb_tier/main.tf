# private NACL

resource "aws_network_acl" "nacl_private" {
  vpc_id  = var.vpc_id

  ingress {
    protocol        = "tcp"
    rule_no         = 100
    action          = "allow"
    cidr_block      = "10.0.1.0/24"
    from_port       = 27017
    to_port         = 27017
  }
  ingress {
    protocol        = "tcp"
    rule_no         = 130
    action          = "allow"
    cidr_block      = "10.1.1.0/24"
    from_port       = 1024
    to_port         = 65535
  }
  # SSH from bastion
  # ingress {
  #   protocol        = "tcp"
  #   rule_no         = 140
  #   action          = "allow"
  #   cidr_block      = "86.174.120.138/32"
  #   from_port       = 22
  #   to_port         = 22
  # }
  egress {
    protocol        = "-1"
    rule_no         = 100
    action          = "allow"
    cidr_block      = "0.0.0.0/0"
    from_port       = 0
    to_port         = 0
  }
  tags = {
    Name = "Private NACL"
  }
}

resource "aws_subnet" "app_subnet_private" {
  vpc_id            = var.vpc_id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-1a"
  tags = {
    Name = "${var.name}Private-Node-Sample-App-Subnet"
  }
}


resource "aws_route_table" "private" {
  vpc_id          = var.vpc_id

  tags = {
    Name          = "${var.name}Node-Sample-App-Private"
  }
}


resource "aws_route_table_association" "assoc" {
  subnet_id       = aws_subnet.app_subnet_private.id
  route_table_id  = aws_route_table.private.id
}

resource "aws_security_group" "elliot_eng54_mongodb_security" {
  name          = "${var.name}mongodb-security"
  description   = "Allow TLS inbound traffic"
  vpc_id        = var.vpc_id

  ingress {
    description = "Allows access on port 27017"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  # SSh from bastion
  # ingress {
  #   description = "Allows access on port 22"
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}mongodb-security"
  }
}


resource "aws_instance" "mongodb" {
  ami                           = var.mongodb_ami_id
  instance_type                 = "t2.micro"
  associate_public_ip_address   = false
  subnet_id                     = aws_subnet.app_subnet_private.id
  vpc_security_group_ids        = [aws_security_group.elliot_eng54_mongodb_security.id]
#  private_ip                    = "10.0.2.44/32"
  tags = {
    Name                        = "${var.name}terraform-mongodb"
  }
  key_name                      = "elliot-eng54"
}
