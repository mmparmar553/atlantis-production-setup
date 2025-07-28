# Development Environment Configuration
# Enterprise Atlantis Demo - Development Settings

# Basic Configuration
aws_region  = "us-west-2"
environment = "dev"

# VPC Configuration
vpc_cidr = "10.10.0.0/16"

# Subnet Configuration
public_subnet_cidrs  = ["10.10.101.0/24", "10.10.102.0/24"]
private_subnet_cidrs = ["10.10.1.0/24", "10.10.2.0/24"]

# Gateway Configuration
enable_nat_gateway = true
enable_vpn_gateway = false

# S3 Configuration
s3_bucket_versioning  = true
s3_lifecycle_enabled  = true

# Security Configuration
allowed_cidr_blocks = [
  "10.10.0.0/16",  # VPC CIDR
  "10.0.0.0/8"     # Private networks only
]
