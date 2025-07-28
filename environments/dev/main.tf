# Development Environment - Enterprise Atlantis Demo
# This demonstrates real Atlantis automation with enterprise security

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
  
  # In production, use remote backend
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "environments/dev/terraform.tfstate"
  #   region = "us-west-2"
  # }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment   = var.environment
      Project       = "atlantis-enterprise-demo"
      ManagedBy     = "atlantis"
      Owner         = "sre-team"
      CostCenter    = "engineering"
      Compliance    = "required"
    }
  }
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Local values for enterprise standards
locals {
  common_tags = {
    Environment = var.environment
    Project     = "atlantis-enterprise"
    ManagedBy   = "atlantis"
    Owner       = "sre-team"
  }
  
  name_prefix = "${var.environment}-atlantis-enterprise"
}
