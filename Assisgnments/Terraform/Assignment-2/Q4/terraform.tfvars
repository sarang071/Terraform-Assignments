vpc-cidr = "10.0.0.0/16"
public_subnet_cidr = ["10.0.0.0/24", "10.0.1.0/24"]
private_subnet_cidr = ["10.0.2.0/24", "10.0.3.0/24"]
zones = [ "ap-south-1a", "ap-south-1b" ]
ssh_key_path = "/root/.ssh/id_rsa.pub"
key_name = "root-key"
rds-sg-basic = ["3306"]
app-sg-basic = ["22", "8080"]