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

# Monitoring Outputs
output "sns_topic_arn" {
  description = "ARN of the infrastructure alerts SNS topic"
  value       = aws_sns_topic.infrastructure_alerts.arn
}

output "cloudwatch_dashboard_url" {
  description = "URL of the CloudWatch dashboard"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.infrastructure.dashboard_name}"
}

output "application_log_group_name" {
  description = "Name of the application log group"
  value       = aws_cloudwatch_log_group.application_logs.name
}

output "monitoring_alarms" {
  description = "List of monitoring alarms created"
  value = {
    s3_bucket_size_alarm    = aws_cloudwatch_metric_alarm.s3_bucket_size.alarm_name
    vpc_flow_log_errors     = aws_cloudwatch_metric_alarm.vpc_flow_log_errors.alarm_name
    security_events_alarm   = aws_cloudwatch_metric_alarm.security_events.alarm_name
    composite_health_alarm  = aws_cloudwatch_composite_alarm.infrastructure_health.alarm_name
  }
}
