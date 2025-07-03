provider "aws" {
  region     = "us-east-1"
  access_key = "acces key"
  secret_key = "security key"
}

# VPC
resource "aws_vpc" "vpc_aysata" {
  cidr_block = "10.0.0.0/16"
}

# Subnet
resource "aws_subnet" "subnet_aysata" {
  vpc_id     = aws_vpc.vpc_aysata.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

# Internet Gateway
resource "aws_internet_gateway" "igw_aysata" {
  vpc_id = aws_vpc.vpc_aysata.id
}

# Route Table
resource "aws_route_table" "route_table_aysata" {
  vpc_id = aws_vpc.vpc_aysata.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_aysata.id
  }
}

# Association route table au subnet
resource "aws_route_table_association" "route_assoc" {
  subnet_id      = aws_subnet.subnet_aysata.id
  route_table_id = aws_route_table.route_table_aysata.id
}

# Security group (SSH only)
resource "aws_security_group" "sg_aysata" {
  name        = "allow_ssh_aysata"
  description = "Allow SSH"
  vpc_id      = aws_vpc.vpc_aysata.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 instance
resource "aws_instance" "myec2" {
  ami                    = "ami-026ebd4cfe2c043b2"
  instance_type          = "t2.micro"
  key_name               = "devops-aysata"
  subnet_id              = aws_subnet.subnet_aysata.id
  vpc_security_group_ids = [aws_security_group.sg_aysata.id]

  root_block_device {
    delete_on_termination = true
  }

  tags = {
    Name = "ec2-aysata"
  }
}
