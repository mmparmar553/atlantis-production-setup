# Production Environment Variables

variable "aws_region" {
  description = "AWS region for production resources"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}
