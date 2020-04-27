# App tier
### All things to do with the App EC2 creation


# Public NACL
resource "aws_network_acl" "nacl_public" {
  vpc_id  = var.vpc_id

  ingress {
    protocol        = "tcp"
    rule_no         = 100
    action          = "allow"
    cidr_block      = "0.0.0.0/0"
    from_port       = 80
    to_port         = 80
  }
  ingress {
    protocol        = "tcp"
    rule_no         = 110
    action          = "allow"
    cidr_block      = "0.0.0.0/0"
    from_port       = 3000
    to_port         = 3000
  }
  ingress {
    protocol        = "tcp"
    rule_no         = 120
    action          = "allow"
    cidr_block      = "0.0.0.0/0"
    from_port       = 443
    to_port         = 443
  }
  ingress {
    protocol        = "tcp"
    rule_no         = 130
    action          = "allow"
    cidr_block      = "0.0.0.0/0"
    from_port       = 1024
    to_port         = 65535
  }
  ingress {
    protocol        = "tcp"
    rule_no         = 140
    action          = "allow"
    cidr_block      = "86.174.120.138/32"
    from_port       = 22
    to_port         = 22
  }
  egress {
    protocol        = "tcp"
    rule_no         = 100
    action          = "allow"
    cidr_block      = "0.0.0.0/0"
    from_port       = 0
    to_port         = 0
  }

  tags = {
    Name = "Public NACL"
  }
}



# Public Subnet
resource "aws_subnet" "app_subnet_elliot" {
  vpc_id            = var.vpc_id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-1a"
  tags = {
    Name = "${var.name}Public-Node-Sample-App-Subnet"
  }
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id          = var.vpc_id
  route {
    cidr_block    = "0.0.0.0/0"
    gateway_id    = var.igw
  }
  tags = {
    Name          = "${var.name}Node-Sample-App-Public"
  }
}

# Route Table Association
resource "aws_route_table_association" "assoc" {
  subnet_id       = aws_subnet.app_subnet_elliot.id
  route_table_id  = aws_route_table.public.id
}


data "template_file" "app_init" {
  template = file("./templates/app_init/init.sh.tpl")
  #.tpl like .erb allow us to interpolate variables into static templates
    # making them dynamic
  vars = {
    my_name = "${var.name} is the real name Elliot"
  }

  # set ports
  # for the mongodb, setting private_ip for db_host
    # AWS gives us new IPs - If we want to make one machine aware of another this could be useful
}

# Launching a resource/instance
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
