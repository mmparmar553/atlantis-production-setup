# S3 Infrastructure for Development Environment
# Enterprise-grade storage with security and compliance features

# Random suffix for globally unique bucket names
resource "random_id" "bucket_suffix" {
  byte_length = 8
}

# Application Storage Bucket
resource "aws_s3_bucket" "app_storage" {
  bucket = "${local.name_prefix}-app-storage-${random_id.bucket_suffix.hex}"

  tags = merge(local.common_tags, {
    Name    = "${local.name_prefix}-app-storage"
    Purpose = "application-storage"
    Type    = "storage"
  })
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "app_storage" {
  bucket = aws_s3_bucket.app_storage.id
  versioning_configuration {
    status = var.s3_bucket_versioning ? "Enabled" : "Suspended"
  }
}

# S3 Bucket Server Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "app_storage" {
  bucket = aws_s3_bucket.app_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# S3 Bucket Public Access Block (Critical Security Control)
resource "aws_s3_bucket_public_access_block" "app_storage" {
  bucket = aws_s3_bucket.app_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Lifecycle Configuration
resource "aws_s3_bucket_lifecycle_configuration" "app_storage" {
  count = var.s3_lifecycle_enabled ? 1 : 0

  bucket = aws_s3_bucket.app_storage.id

  rule {
    id     = "transition_to_ia"
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
      days = 365
    }
  }

  rule {
    id     = "delete_incomplete_multipart_uploads"
    status = "Enabled"

    filter {
      prefix = ""
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# S3 Bucket Policy (HTTPS Only)
resource "aws_s3_bucket_policy" "app_storage" {
  bucket = aws_s3_bucket.app_storage.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureConnections"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.app_storage.arn,
          "${aws_s3_bucket.app_storage.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

# Backup Storage Bucket
resource "aws_s3_bucket" "backup_storage" {
  bucket = "${local.name_prefix}-backup-storage-${random_id.bucket_suffix.hex}"

  tags = merge(local.common_tags, {
    Name    = "${local.name_prefix}-backup-storage"
    Purpose = "backup-storage"
    Type    = "storage"
  })
}

# Backup Bucket Versioning
resource "aws_s3_bucket_versioning" "backup_storage" {
  bucket = aws_s3_bucket.backup_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Backup Bucket Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "backup_storage" {
  bucket = aws_s3_bucket.backup_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# Backup Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "backup_storage" {
  bucket = aws_s3_bucket.backup_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Backup Bucket Lifecycle (Longer retention)
resource "aws_s3_bucket_lifecycle_configuration" "backup_storage" {
  bucket = aws_s3_bucket.backup_storage.id

  rule {
    id     = "backup_lifecycle"
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

    transition {
      days          = 180
      storage_class = "DEEP_ARCHIVE"
    }

    expiration {
      days = 2555  # 7 years retention for backups
    }
  }
}

# Backup Bucket Policy (HTTPS Only)
resource "aws_s3_bucket_policy" "backup_storage" {
  bucket = aws_s3_bucket.backup_storage.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureConnections"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.backup_storage.arn,
          "${aws_s3_bucket.backup_storage.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

# Logs Storage Bucket
resource "aws_s3_bucket" "logs_storage" {
  bucket = "${local.name_prefix}-logs-storage-${random_id.bucket_suffix.hex}"

  tags = merge(local.common_tags, {
    Name    = "${local.name_prefix}-logs-storage"
    Purpose = "logs-storage"
    Type    = "storage"
  })
}

# Logs Bucket Configuration
resource "aws_s3_bucket_versioning" "logs_storage" {
  bucket = aws_s3_bucket.logs_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs_storage" {
  bucket = aws_s3_bucket.logs_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "logs_storage" {
  bucket = aws_s3_bucket.logs_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Logs Bucket Lifecycle (Shorter retention for logs)
resource "aws_s3_bucket_lifecycle_configuration" "logs_storage" {
  bucket = aws_s3_bucket.logs_storage.id

  rule {
    id     = "logs_lifecycle"
    status = "Enabled"

    filter {
      prefix = ""
    }

    transition {
      days          = 7
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 30
      storage_class = "GLACIER"
    }

    expiration {
      days = 90  # 90 days retention for logs
    }
  }
}
