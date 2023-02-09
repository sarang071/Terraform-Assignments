variable "vpc-cidr" {
  type = string
}
variable "public_subnet_cidr" {
  type = string
}
variable "availability_zone" {
  type = string
}
variable "ami-id" {
  type = string
}
variable "type" {
  type = string
}
variable "ssh_key_path" {
  type = string
}
variable "key_name" {
  type = string
}
variable "port" {
  type = list(any)
}
