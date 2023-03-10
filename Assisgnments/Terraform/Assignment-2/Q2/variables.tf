#==================================================================
// Environment
#==================================================================
variable "env" {
  type = string
}
#==================================================================
// VPC
#==================================================================
variable "vpc-cidr" {
  type = string
}
variable "public_subnet_cidr" {
  type = string
}
#==================================================================
// Ssh-Key
#==================================================================
variable "ssh_key_path" {
  type = string
}
variable "key_name" {
  type = string
}
#==================================================================
// EC2
#==================================================================
variable "type" {
  type = list(any)
}
#==================================================================
// Security Groups
#==================================================================
variable "dev-sg-basic" {
  type = list(any)
}
variable "qa-sg-basic" {
  type = list(any)
}