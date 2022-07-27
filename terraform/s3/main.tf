terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">3.0.0"
    }
  }
}


provider "aws" {
  region = var.region
// comment
}


data "aws_iam_user" "input_user" {
  count = "${var.user == "none" ? 0 : 1}"
  user_name = var.user
}

resource "aws_s3_bucket" "bucket" {
  bucket = var.name
  force_destroy = true  

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
    AMAZING_TAG = "AMAZING_VALUE"
  }
}


resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "private"
}

resource "aws_iam_policy" "policy" {
  count = "${var.user == "none" ? 0 : 1}"
  name        = "s3_access_${var.name}"
  path        = "/"
  description = "Policy to access S3 Module"  
  # refactor required here
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
        {
        Effect: "Allow",
        Action: ["s3:ListBucket"],
        Resource: ["arn:aws:s3:::${var.name}"]
        },
        {
        Effect: "Allow",
        Action: [
            "s3:PutObject",
            "s3:GetObject",
            "s3:DeleteObject"
        ],
        Resource: ["arn:aws:s3:::${var.name}/*"]
        }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "attachment" {  
    count = "${var.user == "none" ? 0 : 1}"
    user       = data.aws_iam_user.input_user[0].user_name 
    policy_arn = aws_iam_policy.policy[0].arn
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.bucket.arn
}
