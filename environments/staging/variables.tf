# Staging Environment Variables

variable "aws_region" {
  description = "AWS region for staging resources"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "staging"
}
