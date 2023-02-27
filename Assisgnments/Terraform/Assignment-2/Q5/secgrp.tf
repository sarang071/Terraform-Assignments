#=============================================
# Create Application Load balancer security group
#=============================================
resource "aws_security_group" "alb-sg" {
  name        = "alb-sg"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.ce-vpc.id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  dynamic "egress" {
    for_each = var.sg-basic
    iterator = port
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["10.0.1.0/24"]
    }
  }

  tags = {
    Name = "Alb-SG"
  }
}
#=============================================
# Create Web server security group
#=============================================
resource "aws_security_group" "web-sg" {
  name        = "web-sg"
  description = "Allow 80 and 443 from ALB"
  vpc_id      = aws_vpc.ce-vpc.id

  dynamic "ingress" {
    for_each = var.sg-basic
    iterator = port
    content {
      from_port       = port.value
      to_port         = port.value
      protocol        = "tcp"
      cidr_blocks     = ["10.0.0.0/24"]
      security_groups = ["${aws_security_group.alb-sg.id}"]
    }
  }

  egress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.2.0/24"]
  }

  tags = {
    Name = "Web-SG"
  }
}
#==============================================
# Create Application server security group
#==============================================
resource "aws_security_group" "app-sg" {
  name        = "app-sg"
  description = "Allow 8080"
  vpc_id      = aws_vpc.ce-vpc.id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    cidr_blocks     = ["10.0.1.0/24"]
    security_groups = ["${aws_security_group.web-sg.id}"]
  }

  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.3.0/24"]
  }

  tags = {
    Name = "App-SG"
  }
}
