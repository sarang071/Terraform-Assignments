#==============================================
# Create Application load balancer
#==============================================
resource "aws_lb" "ce-alb" {
  name               = "ce-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = [aws_subnet.public01.id, aws_subnet.public02.id]

  enable_deletion_protection = false

  tags = {
    name = "ce-alb"
  }
}
