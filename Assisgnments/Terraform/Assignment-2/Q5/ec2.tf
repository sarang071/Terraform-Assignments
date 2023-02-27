#==============================================
# Create Web server instance
#==============================================
resource "aws_instance" "web-server" {
  ami             = "ami-0cca134ec43cf708f"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.public02.id
  security_groups = ["${aws_security_group.web-sg.id}"]
}
#=============================================
# Create App server instance
#=============================================
resource "aws_instance" "app-server" {
  ami             = "ami-0cca134ec43cf708f"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.private01.id
  security_groups = ["${aws_security_group.app-sg.id}"]
}
