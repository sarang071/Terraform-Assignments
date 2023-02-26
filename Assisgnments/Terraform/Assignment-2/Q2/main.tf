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

data "aws_ami" "qa_ami_image" {
  most_recent      = true
  owners           = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
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
// VPC
#==================================================================
resource "aws_vpc" "CE-vpc" {
  cidr_block       = var.vpc-cidr
}
#==================================================================
// Public Subnet
#==================================================================
resource "aws_subnet" "public_subnet" {
    vpc_id            = aws_vpc.CE-vpc.id
   cidr_block        = var.public_subnet_cidr
   availability_zone = "ap-south-1a"
}
#==================================================================
// IGW
#==================================================================
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.CE-vpc.id
}
#==================================================================
// Route tables
#==================================================================
resource "aws_route_table" "Public-RT" {
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
#==================================================================
// RT Association
#==================================================================
resource "aws_route_table_association" "pub-asso" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.Public-RT.id
}
#==================================================================
//ssh key
#==================================================================
resource "aws_key_pair" "this_key" {
  key_name   = var.key_name
  public_key = file(var.ssh_key_path)
}
#==================================================================
// EC2
#==================================================================
resource "aws_instance" "this_dev_ec2" {
  count                   = var.env == "dev" ? 2:0
  ami                     = data.aws_ami.dev_ami_image.id
  instance_type           = var.type[0]
  key_name                = aws_key_pair.this_key.key_name
  subnet_id               = aws_subnet.public_subnet.id
  security_groups         = [aws_security_group.dev-sg.id]
}
resource "aws_instance" "this_qa_ec2" {
  count                   = var.env == "qa" ? 1:0
  ami                     = data.aws_ami.dev_ami_image.id
  instance_type           = var.type[1]
  key_name                = aws_key_pair.this_key.key_name
  subnet_id               = aws_subnet.public_subnet.id
  security_groups         = [aws_security_group.qa-sg.id]
}
#==================================================================
// Security Groups
#==================================================================
resource "aws_security_group" "dev-sg" {
  name        = "dev-sg"
  description = "Allow 22, 80 and 443"
  vpc_id      = "${aws_vpc.CE-vpc.id}"

  dynamic "ingress" {
    for_each = var.dev-sg-basic
    iterator = port
    content {
      from_port       = port.value
      to_port         = port.value
      protocol        = "tcp"
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "qa-sg" {
  name        = "qa-sg"
  description = "Allow 22, 8080 and 3306"
  vpc_id      = aws_vpc.CE-vpc.id

  dynamic "ingress" {
    for_each = var.qa-sg-basic
    iterator = port
    content {
      from_port       = port.value
      to_port         = port.value
      protocol        = "tcp"
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}