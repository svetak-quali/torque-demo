resource "aws_s3_bucket" "bucket" {
  bucket = var.name
  force_destroy = true  



 tags = {
    Name        = "My bucket"
    Environment = "Dev"
    AMAZING_TAG = "AMAZING_VALUE"
  }
}
