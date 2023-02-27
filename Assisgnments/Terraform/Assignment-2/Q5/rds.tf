#==============================================
# Create RDS instance
#==============================================
resource "aws_db_subnet_group" "rds-subnet-group" {
  name       = "rds-subnet-group"
  subnet_ids = ["${aws_subnet.private01.id}", "${aws_subnet.private02.id}"]
}
resource "aws_db_instance" "ce-rds" {
  allocated_storage      = 10
  db_name                = "mydb"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  username               = "sarang"
  password               = "foobarbaz"
  parameter_group_name   = "default.mysql5.7"
  publicly_accessible    = false
  skip_final_snapshot    = true
  vpc_security_group_ids = ["${aws_security_group.app-sg.id}"]
  db_subnet_group_name   = aws_db_subnet_group.rds-subnet-group.name

}
