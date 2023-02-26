terraform {
  required_version = ">= 0.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.48.0"
    }
  }
}
// VPC
resource "aws_vpc" "CE-vpc" {
  cidr_block       = var.vpc-cidr
}
// Public Subnet
resource "aws_subnet" "public_subnet" {
  count             = 2
  vpc_id            = aws_vpc.CE-vpc.id
  cidr_block        = element (var.public_subnet_cidr,count.index)
  availability_zone = element (var.availability_zone,count.index)
}
// Private Subnet
resource "aws_subnet" "private_subnet" {
  count             = 2
  vpc_id            = aws_vpc.CE-vpc.id
  cidr_block        = element (var.private_subnet_cidr,count.index)
  availability_zone = element (var.availability_zone,count.index)
}
//NAT gateway
resource "aws_eip" "eip" {
  vpc = true
}
resource "aws_nat_gateway" "NAT" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnet[0].id
}
// IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.CE-vpc.id
}
// Route tables
resource "aws_route_table" "Public-RT" {
  vpc_id = aws_vpc.CE-vpc.id
}
resource "aws_route_table" "Private-RT" {
  vpc_id = aws_vpc.CE-vpc.id
}
// Routes
resource "aws_route" "Pub-route" {
  route_table_id              = aws_route_table.Public-RT.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id      = aws_internet_gateway.igw.id
}
resource "aws_route" "Pri-route" {
  route_table_id              = aws_route_table.Private-RT.id
  destination_cidr_block      =   "0.0.0.0/0"
  gateway_id      = aws_nat_gateway.NAT.id
}
// RT Association
resource "aws_route_table_association" "pub-asso" {
  count          = length(var.public_subnet_cidr)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.Public-RT.id
}
resource "aws_route_table_association" "pri-asso" {
  count          = length(var.private_subnet_cidr)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.Private-RT.id
}
