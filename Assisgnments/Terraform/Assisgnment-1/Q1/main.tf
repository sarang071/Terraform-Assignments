terraform {
  required_version = ">= 0.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.48.0"
    }
  }
}

resource "aws_iam_user" "user01" {
  name = var.username 
}
resource "aws_iam_user_policy" "ec2-policy" {
  name = var.policy-name
  user = aws_iam_user.user01.name
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF 
}
resource "aws_iam_group" "group01" {
  name = var.group-name 
}
resource "aws_iam_group_membership" "team" {
  name = var.membership-name

  users = [
    aws_iam_user.user01.name
  ]

  group = aws_iam_group.group01.name
}
