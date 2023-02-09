terraform {
  required_version = ">= 0.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.48.0"
    }
  }
}
resource "aws_eip" "eip" {
  vpc = true
}
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.this.id
  allocation_id = aws_eip.eip.id
}
resource "aws_instance" "this" {
  ami                     = var.ami-id
  instance_type           = var.type
  availability_zone       = var.availability_zone
}
