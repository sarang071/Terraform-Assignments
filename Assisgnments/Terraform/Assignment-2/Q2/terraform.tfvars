env = "qa"
vpc-cidr = "10.0.0.0/16"
public_subnet_cidr = "10.0.0.0/24"
ssh_key_path = "/root/.ssh/id_rsa.pub"
key_name = "root-key"
type = ["t2.micro", "t2.small"]
dev-sg-basic = ["80", "22", "443"]
qa-sg-basic = ["22", "8080","3306"]