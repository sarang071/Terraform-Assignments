vpc-cidr = "10.0.0.0/16"
public_subnet_cidr = "10.0.0.0/24"
availability_zone = "us-east-1a"
ami-id = "ami-0aa7d40eeae50c9a9"
type   = "t2.micro"
ssh_key_path = "/root/.ssh/id_rsa.pub"
key_name = "root-key"
port = ["22","80"]