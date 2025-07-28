# Production Environment Outputs

output "s3_bucket_name" {
  description = "Name of the simple S3 bucket"
  value       = aws_s3_bucket.simple_storage.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the simple S3 bucket"
  value       = aws_s3_bucket.simple_storage.arn
}

output "s3_bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.simple_storage.bucket_domain_name
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}

output "lifecycle_policy_enabled" {
  description = "Whether lifecycle policy is enabled"
  value       = true
}
