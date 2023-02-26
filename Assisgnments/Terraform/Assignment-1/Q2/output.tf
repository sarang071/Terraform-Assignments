output "ec2-public-ip" {
  value = aws_instance.this.public_ip
}
output "ec2-public-dns" {
  value = aws_instance.this.public_dns
}
output "ec2-private-ip" {
  value = aws_instance.this.private_ip
}
output "ec2-private-dns" {
  value = aws_instance.this.private_dns
}