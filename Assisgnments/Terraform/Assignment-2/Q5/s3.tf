resource "aws_s3_bucket" "ce-s3-7709714182" {
  bucket = "ce-s3-7709714282"

  tags = {
    Name        = "ce-s3"
    Environment = "Dev"
  }
}
#