terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.56.0"
    }
  }
}
resource "aws_iam_user" "users" {
  name = "sarang_${count.index}"
  count = 3
  path = "/system/"
}
resource "aws_iam_group" "groups" {
  name = "dev_${count.index}"
  count = 3
  path = "/users/"
}
resource "aws_iam_user_group_membership" "membership" {
  user = aws_iam_user.users[count.index].name
  count = 3

  groups = [
    aws_iam_group.groups[count.index].name
  ]
}