# Simple S3 Bucket for Production Environment
# This demonstrates Atlantis automation with enhanced production security

# Random suffix for globally unique bucket names
resource "random_id" "s3_suffix" {
  byte_length = 4
}

# Simple S3 Bucket with enhanced production security
resource "aws_s3_bucket" "simple_storage" {
  bucket = "${var.environment}-atlantis-simple-${random_id.s3_suffix.hex}"

  tags = merge(local.common_tags, {
    Name    = "${var.environment}-simple-storage"
    Purpose = "atlantis-testing"
    Type    = "storage"
  })
}

# Enable versioning (critical for production)
resource "aws_s3_bucket_versioning" "simple_storage" {
  bucket = aws_s3_bucket.simple_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable encryption (required for production)
resource "aws_s3_bucket_server_side_encryption_configuration" "simple_storage" {
  bucket = aws_s3_bucket.simple_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# Block public access (critical for production)
resource "aws_s3_bucket_public_access_block" "simple_storage" {
  bucket = aws_s3_bucket.simple_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Production-specific lifecycle policy
resource "aws_s3_bucket_lifecycle_configuration" "simple_storage" {
  bucket = aws_s3_bucket.simple_storage.id

  rule {
    id     = "production_lifecycle"
    status = "Enabled"

    filter {
      prefix = ""
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 2555  # 7 years for production data
    }
  }
}
