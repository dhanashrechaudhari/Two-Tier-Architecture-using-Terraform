variable "region" {
    default = "us-east-1"
  
}
variable "az_1" {
  default = "us-east-1a"
}
variable "az_2" {
    default = "us-east-1b"
  
}
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "private_cidr" {
  default = "10.0.0.0/20"
}
variable "public_cidr" {
  default = "10.0.16.0/20"
}

variable "project_name" {
  default = "FCT"
}
variable "IGW-cidr" {
  default = "0.0.0.0/0"
}
variable "ami" {
  default = "ami-01edba92f9036f76e"
}
variable "instance_type" {
  default = "t3.micro"
}
variable "key_name" {
  default = "demo"
}