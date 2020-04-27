variable "vpc_id" {
  description = "The VPC is launches resources into"
}

variable "name" {
  description = "Name set to 'elliot-eng54-''"
}

variable "ami_id" {
  description = "AMI containing Node Sample App"
}

variable "gateway_id_var" {
  description = "data.aws_internet_gateway.default_gw.id"
}
