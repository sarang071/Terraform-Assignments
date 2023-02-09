variable "vpc-cidr" {
  type = string
}
variable "public_subnet_cidr" {
  type = list(any)
}
variable "private_subnet_cidr" {
  type = list(any)
}
variable "availability_zone" {
  type = list(any)
}
