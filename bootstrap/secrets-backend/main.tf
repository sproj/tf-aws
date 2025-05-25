resource "aws_s3_bucket" "k8s_secrets" {
  bucket = "tfaws-${var.env}-secrets"
  
  tags = {
    Name        = "Kubernetes Secrets Bucket"
    Environment = var.env
    Project     = "tfaws-bootstrap"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "k8s_secrets" {
  bucket = aws_s3_bucket.k8s_secrets.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.k8s_secrets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}