resource "aws_s3_bucket" "this" {
  bucket = "state-bucket-for-eks-deployment"

  tags = {
    task  = "app deployment on eks cluster"
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}