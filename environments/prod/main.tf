# Production Environment - Simple Atlantis Demo

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
      Criticality   = "high"
    }
  }
}

# Local values
locals {
  common_tags = {
    Environment = var.environment
    Project     = "atlantis-enterprise"
    ManagedBy   = "atlantis"
    Owner       = "sre-team"
    Criticality = "high"
  }
  
  name_prefix = "${var.environment}-atlantis-enterprise"
}
