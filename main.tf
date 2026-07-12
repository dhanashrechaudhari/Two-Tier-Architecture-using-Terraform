terraform {
  backend "s3" {
    bucket = "terraform-backend-c66-bucket"
    key = "terraform.tfstate"
    region = "us-east-1"
    
  }
}

provider "aws" {
  region = var.region
}
# create a vpc
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# create a private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = var.private_cidr
  availability_zone = var.az_1
  tags = {
    Name = "${var.project_name}-private-subnet"
  }
}

# craete a public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = var.public_cidr
  availability_zone = var.az_2
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}

# create a Internet gateway
resource "aws_internet_gateway" "my_IGW" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "${var.project_name}-IGW"
  }
}

# create a default Route Tabel
resource "aws_default_route_table" "main_RT" {
  default_route_table_id = aws_vpc.my_vpc.default_route_table_id
  tags = {
    Name = "${var.project_name}-main-RT"
  }
}
# add a route in main route table
resource "aws_route" "aws_route" {
  route_table_id = aws_default_route_table.main_RT.id
  destination_cidr_block = var.IGW-cidr
  gateway_id = aws_internet_gateway.my_IGW.id
}

# create a security group

resource "aws_security_group" "my_sg" {
  vpc_id = aws_vpc.my_vpc.id
  name = "${var.project_name}-SG"
  description = "allow ssh,http,mysql traffic"
  ingress {
    protocol = "tcp"
    to_port = 22
    from_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol = "tcp"
    to_port = 80
    from_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
ingress {
    protocol = "tcp"
    to_port = 3306
    from_port = 3306
    cidr_blocks = ["0.0.0.0/0"]
   }
   egress {
    protocol = -1
    to_port = 0
    from_port = 0
    cidr_blocks = ["0.0.0.0/0"]
   }
   depends_on = [ aws_vpc.my_vpc ] # explicite dependency
}

# create a public server
resource "aws_instance" "public-server" {
  subnet_id = aws_subnet.public_subnet.id
  ami = var.ami
  instance_type = var.instance_type
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  tags = {
    Name = "${var.project_name}-app-server"
  }
  depends_on = [ aws_security_group.my_sg ]
}

# create a private server 
resource "aws_instance" "Private-server" {
    subnet_id = aws_subnet.private_subnet.id
    ami = var.ami
    instance_type = var.instance_type
    key_name = var.key_name
    vpc_security_group_ids = [aws_security_group.my_sg.id]
    tags = {
      Name = "${var.project_name}-db-server"
    }
  depends_on = [ aws_security_group.my_sg ]
}