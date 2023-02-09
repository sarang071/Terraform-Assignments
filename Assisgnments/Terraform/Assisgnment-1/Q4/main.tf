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
    vpc_id            = aws_vpc.CE-vpc.id
   cidr_block        = var.public_subnet_cidr
   availability_zone = var.availability_zone
}
// IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.CE-vpc.id
}
// Route tables
resource "aws_route_table" "Public-RT" {
  vpc_id = aws_vpc.CE-vpc.id
}
// Routes
resource "aws_route" "Pub-route" {
  route_table_id              = aws_route_table.Public-RT.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id      = aws_internet_gateway.igw.id
}
// RT Association
resource "aws_route_table_association" "pub-asso" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.Public-RT.id
}
//ssh key
resource "aws_key_pair" "this_key" {
  key_name   = var.key_name
  public_key = file(var.ssh_key_path)
}
// EC2
resource "aws_instance" "this" {
  ami                     = var.ami-id
  instance_type           = var.type
  key_name = aws_key_pair.this_key.key_name
}