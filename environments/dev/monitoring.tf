# Monitoring Infrastructure for Development Environment
# Enterprise-grade monitoring with CloudWatch, SNS, and alerting

# SNS Topic for Infrastructure Alerts
resource "aws_sns_topic" "infrastructure_alerts" {
  name = "${local.name_prefix}-infrastructure-alerts"

  tags = merge(local.common_tags, {
    Name    = "${local.name_prefix}-infrastructure-alerts"
    Purpose = "infrastructure-monitoring"
    Type    = "monitoring"
  })
}

# SNS Topic Policy
resource "aws_sns_topic_policy" "infrastructure_alerts" {
  arn = aws_sns_topic.infrastructure_alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.infrastructure_alerts.arn
      }
    ]
  })
}

# CloudWatch Dashboard for Infrastructure Monitoring
resource "aws_cloudwatch_dashboard" "infrastructure" {
  dashboard_name = "${local.name_prefix}-infrastructure-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/S3", "BucketSizeBytes", "BucketName", aws_s3_bucket.app_storage.bucket, "StorageType", "StandardStorage"],
            ["AWS/S3", "NumberOfObjects", "BucketName", aws_s3_bucket.app_storage.bucket, "StorageType", "AllStorageTypes"]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "S3 Storage Metrics"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/VPC", "PacketDropCount", "VpcId", aws_vpc.main.id]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "VPC Network Metrics"
          period  = 300
        }
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name    = "${local.name_prefix}-infrastructure-dashboard"
    Purpose = "infrastructure-monitoring"
    Type    = "monitoring"
  })
}

# CloudWatch Alarm for S3 Bucket Size
resource "aws_cloudwatch_metric_alarm" "s3_bucket_size" {
  alarm_name          = "${local.name_prefix}-s3-bucket-size-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "BucketSizeBytes"
  namespace           = "AWS/S3"
  period              = "86400"  # 24 hours
  statistic           = "Average"
  threshold           = "1073741824"  # 1GB in bytes
  alarm_description   = "This metric monitors S3 bucket size"
  alarm_actions       = [aws_sns_topic.infrastructure_alerts.arn]

  dimensions = {
    BucketName  = aws_s3_bucket.app_storage.bucket
    StorageType = "StandardStorage"
  }

  tags = merge(local.common_tags, {
    Name    = "${local.name_prefix}-s3-size-alarm"
    Purpose = "cost-monitoring"
    Type    = "monitoring"
  })
}

# CloudWatch Alarm for VPC Flow Log Errors
resource "aws_cloudwatch_metric_alarm" "vpc_flow_log_errors" {
  alarm_name          = "${local.name_prefix}-vpc-flow-log-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ErrorCount"
  namespace           = "AWS/Logs"
  period              = "300"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "This metric monitors VPC flow log errors"
  alarm_actions       = [aws_sns_topic.infrastructure_alerts.arn]

  dimensions = {
    LogGroupName = aws_cloudwatch_log_group.vpc_flow_log.name
  }

  tags = merge(local.common_tags, {
    Name    = "${local.name_prefix}-vpc-flow-errors"
    Purpose = "security-monitoring"
    Type    = "monitoring"
  })
}

# CloudWatch Log Metric Filter for Security Events
resource "aws_cloudwatch_log_metric_filter" "security_events" {
  name           = "${local.name_prefix}-security-events"
  log_group_name = aws_cloudwatch_log_group.vpc_flow_log.name
  pattern        = "[version, account, eni, source, destination, srcport, destport=\"22\", protocol=\"6\", packets, bytes, windowstart, windowend, action=\"REJECT\"]"

  metric_transformation {
    name      = "SecurityRejectedSSH"
    namespace = "Custom/Security"
    value     = "1"
  }
}

# CloudWatch Alarm for Security Events
resource "aws_cloudwatch_metric_alarm" "security_events" {
  alarm_name          = "${local.name_prefix}-security-ssh-rejected"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "SecurityRejectedSSH"
  namespace           = "Custom/Security"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "This metric monitors rejected SSH attempts"
  alarm_actions       = [aws_sns_topic.infrastructure_alerts.arn]

  tags = merge(local.common_tags, {
    Name    = "${local.name_prefix}-security-ssh-alarm"
    Purpose = "security-monitoring"
    Type    = "monitoring"
  })
}

# CloudWatch Composite Alarm for Infrastructure Health
resource "aws_cloudwatch_composite_alarm" "infrastructure_health" {
  alarm_name        = "${local.name_prefix}-infrastructure-health"
  alarm_description = "Composite alarm for overall infrastructure health"

  alarm_rule = join(" OR ", [
    "ALARM(${aws_cloudwatch_metric_alarm.s3_bucket_size.alarm_name})",
    "ALARM(${aws_cloudwatch_metric_alarm.vpc_flow_log_errors.alarm_name})",
    "ALARM(${aws_cloudwatch_metric_alarm.security_events.alarm_name})"
  ])

  actions_enabled = true
  alarm_actions   = [aws_sns_topic.infrastructure_alerts.arn]

  tags = merge(local.common_tags, {
    Name    = "${local.name_prefix}-composite-health"
    Purpose = "infrastructure-monitoring"
    Type    = "monitoring"
  })
}

# CloudWatch Log Group for Application Logs
resource "aws_cloudwatch_log_group" "application_logs" {
  name              = "/aws/application/${local.name_prefix}"
  retention_in_days = 30

  tags = merge(local.common_tags, {
    Name    = "${local.name_prefix}-app-logs"
    Purpose = "application-monitoring"
    Type    = "monitoring"
  })
}

# CloudWatch Log Stream for Application Logs
resource "aws_cloudwatch_log_stream" "application_logs" {
  name           = "${local.name_prefix}-app-stream"
  log_group_name = aws_cloudwatch_log_group.application_logs.name
}
