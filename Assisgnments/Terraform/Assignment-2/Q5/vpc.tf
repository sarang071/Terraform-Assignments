#=============================================
# Create VPC
#=============================================
resource "aws_vpc" "ce-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "ce-vpc"
  }
}
#=============================================
# Public subnets
#=============================================
resource "aws_subnet" "public01" {
  vpc_id            = aws_vpc.ce-vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = var.az[0]
}
resource "aws_subnet" "public02" {
  vpc_id            = aws_vpc.ce-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.az[1]
}
#=============================================
# Private subnets
#=============================================
resource "aws_subnet" "private01" {
  vpc_id            = aws_vpc.ce-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.az[0]
}
resource "aws_subnet" "private02" {
  vpc_id            = aws_vpc.ce-vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = var.az[1]
}
#=============================================
# Create IGW and NAT
#=============================================
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.ce-vpc.id
}
resource "aws_eip" "eip" {
  vpc = true
}
resource "aws_nat_gateway" "my-nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.private01.id
}
#=============================================
# Create Route tables
#=============================================
resource "aws_route_table" "pub-rt01" {
  vpc_id = aws_vpc.ce-vpc.id
}
resource "aws_route_table" "pri-rt01" {
  vpc_id = aws_vpc.ce-vpc.id
}
resource "aws_route_table" "pub-rt02" {
  vpc_id = aws_vpc.ce-vpc.id
}
resource "aws_route_table" "pri-rt02" {
  vpc_id = aws_vpc.ce-vpc.id
}
#=============================================
# Create Route
#=============================================
resource "aws_route" "route-pub01" {
  route_table_id         = aws_route_table.pub-rt01.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}
resource "aws_route" "route-pri01" {
  route_table_id         = aws_route_table.pri-rt02.id
  destination_cidr_block = "10.0.2.0/24"
  gateway_id             = aws_nat_gateway.my-nat.id
}
resource "aws_route" "route-pub02" {
  route_table_id         = aws_route_table.pub-rt02.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}
resource "aws_route" "route-pri02" {
  route_table_id         = aws_route_table.pri-rt02.id
  destination_cidr_block = "10.0.3.0/24"
  gateway_id             = aws_nat_gateway.my-nat.id
}
#==============================================
# Create Associations
#==============================================
resource "aws_route_table_association" "pub-asso" {
  subnet_id      = aws_subnet.public01.id
  route_table_id = aws_route_table.pub-rt01.id
}
resource "aws_route_table_association" "pri-asso" {
  subnet_id      = aws_subnet.private01.id
  route_table_id = aws_route_table.pri-rt01.id
}
resource "aws_route_table_association" "pub-asso2" {
  subnet_id      = aws_subnet.public02.id
  route_table_id = aws_route_table.pub-rt02.id
}
resource "aws_route_table_association" "pri-asso2" {
  subnet_id      = aws_subnet.private02.id
  route_table_id = aws_route_table.pri-rt02.id
}
