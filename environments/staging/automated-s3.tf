# Automated S3 Bucket Test - Staging Environment
# This will be deployed automatically via Atlantis webhooks

resource "random_id" "automated_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "automated_test" {
  bucket = "staging-atlantis-automated-${random_id.automated_suffix.hex}"

  tags = {
    Name        = "staging-automated-test-bucket"
    Environment = "staging"
    ManagedBy   = "atlantis"
    Purpose     = "automated-testing"
    Project     = "atlantis-webhook-test"
    Owner       = "sre-team"
    CreatedBy   = "atlantis-automation"
    Criticality = "medium"
  }
}

resource "aws_s3_bucket_versioning" "automated_test" {
  bucket = aws_s3_bucket.automated_test.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "automated_test" {
  bucket = aws_s3_bucket.automated_test.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "automated_test" {
  bucket = aws_s3_bucket.automated_test.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Output for verification
output "automated_bucket_name" {
  description = "Name of the automated test bucket"
  value       = aws_s3_bucket.automated_test.id
}

output "automated_bucket_arn" {
  description = "ARN of the automated test bucket"
  value       = aws_s3_bucket.automated_test.arn
}
