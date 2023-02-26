#==================================================================
// Provider
#==================================================================
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.52.0"
    }
  }
}
#==================================================================
// VPC
#==================================================================
resource "aws_vpc" "CE-vpc" {
  cidr_block       = var.vpc-cidr
}
#==================================================================
// Public Subnet
#==================================================================
resource "aws_subnet" "public_subnet" {
    count            = length(var.public_subnet_cidr)
    vpc_id           = aws_vpc.CE-vpc.id
   cidr_block        = var.public_subnet_cidr[count.index]
   availability_zone = var.zones[count.index]
}
#==================================================================
// Private Subnet
#==================================================================
resource "aws_subnet" "private_subnet" {
    count            = length(var.private_subnet_cidr)
    vpc_id           = aws_vpc.CE-vpc.id
   cidr_block        = var.private_subnet_cidr[count.index]
   availability_zone = var.zones[count.index]
}
#==================================================================
// IGW
#==================================================================
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.CE-vpc.id
}
#==================================================================
// NAT Gateway
#==================================================================
resource "aws_eip" "this-eip" {
  vpc = true
}
resource "aws_nat_gateway" "NAT" {
  allocation_id = aws_eip.this-eip.id
  subnet_id     = aws_subnet.public_subnet[1].id
}
#==================================================================
// Route tables
#==================================================================
resource "aws_route_table" "Public-RT" {
  vpc_id = aws_vpc.CE-vpc.id
}
resource "aws_route_table" "Private-RT" {
  vpc_id = aws_vpc.CE-vpc.id
}
#==================================================================
// Routes
#==================================================================
resource "aws_route" "Pub-route" {
  route_table_id              = aws_route_table.Public-RT.id
  destination_cidr_block      = "0.0.0.0/0"
  gateway_id                  = aws_internet_gateway.igw.id
}
resource "aws_route" "Pri-route" {
  route_table_id              = aws_route_table.Private-RT.id
  destination_cidr_block      = "0.0.0.0/0"
  gateway_id                  = aws_nat_gateway.NAT.id
}
#==================================================================
// RT Association
#==================================================================
resource "aws_route_table_association" "pub-asso" {
  subnet_id      = aws_subnet.public_subnet[0].id
  route_table_id = aws_route_table.Public-RT.id
}
resource "aws_route_table_association" "pri-asso" {
  subnet_id      = aws_subnet.private_subnet[0].id
  route_table_id = aws_route_table.Private-RT.id
}
#==================================================================
//ssh key
#==================================================================
resource "aws_key_pair" "this_key" {
  key_name   = var.key_name
  public_key = file(var.ssh_key_path)
}
#==================================================================
//Application Load Balancer
#==================================================================
resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = [aws_subnet.public_subnet[0].id, aws_subnet.public_subnet[1].id]
  enable_deletion_protection = false
}
#==================================================================
// AMI Image
#==================================================================
data "aws_ami" "dev_ami_image" {
  most_recent      = true
  owners           = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
#==================================================================
// EC2
#==================================================================
resource "aws_instance" "this_ec2" {
  ami                     = data.aws_ami.dev_ami_image.id
  instance_type           = "t2.micro"
  key_name                = aws_key_pair.this_key.key_name
  subnet_id               = aws_subnet.public_subnet[1].id
  security_groups         = [aws_security_group.web-sg.id]
}
#==================================================================
// Security Groups
#==================================================================
resource "aws_security_group" "alb-sg" {
  name        = "alb-sg"
  description = "Allow 80 and 443"
  vpc_id      = aws_vpc.CE-vpc.id

  dynamic "ingress" {
    for_each = var.alb-sg-basic
    iterator = port
    content {
      from_port       = port.value
      to_port         = port.value
      protocol        = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "web-sg" {
  name        = "web-sg"
  description = "Allow 22, 80"
  vpc_id      = aws_vpc.CE-vpc.id

  dynamic "ingress" {
    for_each = var.web-sg-basic
    iterator = port
    content {
      from_port       = port.value
      to_port         = port.value
      protocol        = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}