# Development Environment Outputs - Enterprise Atlantis

# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "vpc_arn" {
  description = "ARN of the VPC"
  value       = aws_vpc.main.arn
}

# Subnet Outputs
output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "public_subnet_cidrs" {
  description = "CIDR blocks of public subnets"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_cidrs" {
  description = "CIDR blocks of private subnets"
  value       = aws_subnet.private[*].cidr_block
}

# Gateway Outputs
output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = aws_nat_gateway.main[*].id
}

output "nat_gateway_public_ips" {
  description = "Public IPs of the NAT Gateways"
  value       = aws_eip.nat[*].public_ip
}

# Security Group Outputs
output "web_security_group_id" {
  description = "ID of the web security group"
  value       = aws_security_group.web.id
}

output "app_security_group_id" {
  description = "ID of the application security group"
  value       = aws_security_group.app.id
}

output "database_security_group_id" {
  description = "ID of the database security group"
  value       = aws_security_group.database.id
}

output "management_security_group_id" {
  description = "ID of the management security group"
  value       = aws_security_group.management.id
}

# S3 Bucket Outputs
output "app_storage_bucket_name" {
  description = "Name of the application storage S3 bucket"
  value       = aws_s3_bucket.app_storage.bucket
}

output "app_storage_bucket_arn" {
  description = "ARN of the application storage S3 bucket"
  value       = aws_s3_bucket.app_storage.arn
}

output "app_storage_bucket_domain_name" {
  description = "Domain name of the application storage S3 bucket"
  value       = aws_s3_bucket.app_storage.bucket_domain_name
}

output "backup_storage_bucket_name" {
  description = "Name of the backup storage S3 bucket"
  value       = aws_s3_bucket.backup_storage.bucket
}

output "backup_storage_bucket_arn" {
  description = "ARN of the backup storage S3 bucket"
  value       = aws_s3_bucket.backup_storage.arn
}

output "logs_storage_bucket_name" {
  description = "Name of the logs storage S3 bucket"
  value       = aws_s3_bucket.logs_storage.bucket
}

output "logs_storage_bucket_arn" {
  description = "ARN of the logs storage S3 bucket"
  value       = aws_s3_bucket.logs_storage.arn
}

# Environment Information
output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}

output "availability_zones" {
  description = "Availability zones used"
  value       = data.aws_availability_zones.available.names
}

# Monitoring Outputs
output "vpc_flow_log_group_name" {
  description = "Name of the VPC flow log CloudWatch log group"
  value       = aws_cloudwatch_log_group.vpc_flow_log.name
}

output "vpc_flow_log_group_arn" {
  description = "ARN of the VPC flow log CloudWatch log group"
  value       = aws_cloudwatch_log_group.vpc_flow_log.arn
}

# Resource Counts for Cost Tracking
output "resource_counts" {
  description = "Count of resources created for cost tracking"
  value = {
    vpc_count                = 1
    public_subnets_count     = length(aws_subnet.public)
    private_subnets_count    = length(aws_subnet.private)
    nat_gateways_count       = length(aws_nat_gateway.main)
    security_groups_count    = 4
    s3_buckets_count         = 3
    cloudwatch_log_groups    = 1
  }
}
