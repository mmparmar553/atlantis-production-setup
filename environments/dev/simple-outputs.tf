# Simple S3 Outputs for Development Environment

output "simple_s3_bucket_name" {
  description = "Name of the simple S3 bucket"
  value       = aws_s3_bucket.simple_storage.bucket
}

output "simple_s3_bucket_arn" {
  description = "ARN of the simple S3 bucket"
  value       = aws_s3_bucket.simple_storage.arn
}

output "simple_s3_bucket_region" {
  description = "Region of the simple S3 bucket"
  value       = aws_s3_bucket.simple_storage.region
}
