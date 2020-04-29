variable "vpc_id" {
  description = "The VPC is launches resources into"
}

variable "name" {
  description = "Name set to 'elliot-eng54-''"
}

variable "app_ami_id" {
  description = "AMI containing Node Sample App"
}

# making our own igw
# variable "gateway_id_var" {
#   description = "data.aws_internet_gateway.default_gw.id"
# }

variable "igw" {
  description = "igw from main main"
}

variable "mongodb_private_IP" {
  default = "Private IP for mongodb"
}
