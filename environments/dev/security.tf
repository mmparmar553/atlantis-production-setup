# Security Groups and Network ACLs for Development Environment
# Enterprise security with defense in depth

# Web Tier Security Group
resource "aws_security_group" "web" {
  name_prefix = "${local.name_prefix}-web-"
  vpc_id      = aws_vpc.main.id
  description = "Security group for web tier - allows HTTP/HTTPS from internet, SSH from VPC"

  # HTTP from anywhere
  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS from anywhere
  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH from allowed CIDR blocks only
  ingress {
    description = "SSH from allowed networks"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  # All outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-web-sg"
    Tier = "web"
    Type = "security"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Application Tier Security Group
resource "aws_security_group" "app" {
  name_prefix = "${local.name_prefix}-app-"
  vpc_id      = aws_vpc.main.id
  description = "Security group for application tier - allows traffic from web tier only"

  # Application port from web tier
  ingress {
    description     = "Application port from web tier"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  # SSH from web tier for management
  ingress {
    description     = "SSH from web tier"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  # All outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-app-sg"
    Tier = "application"
    Type = "security"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Database Tier Security Group
resource "aws_security_group" "database" {
  name_prefix = "${local.name_prefix}-db-"
  vpc_id      = aws_vpc.main.id
  description = "Security group for database tier - allows traffic from app tier only"

  # MySQL/Aurora from application tier
  ingress {
    description     = "MySQL/Aurora from application tier"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  # PostgreSQL from application tier
  ingress {
    description     = "PostgreSQL from application tier"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  # No outbound rules - databases shouldn't initiate outbound connections
  # Outbound rules will be added only if specifically needed

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-db-sg"
    Tier = "database"
    Type = "security"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Management Security Group (for bastion hosts, monitoring, etc.)
resource "aws_security_group" "management" {
  name_prefix = "${local.name_prefix}-mgmt-"
  vpc_id      = aws_vpc.main.id
  description = "Security group for management resources"

  # SSH from allowed CIDR blocks
  ingress {
    description = "SSH from allowed networks"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  # HTTPS for management interfaces
  ingress {
    description = "HTTPS for management"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  # All outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-mgmt-sg"
    Tier = "management"
    Type = "security"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Network ACL for additional security layer
resource "aws_network_acl" "private" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.private[*].id

  # Allow inbound traffic from VPC
  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 0
    to_port    = 0
  }

  # Allow outbound traffic to VPC
  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 0
    to_port    = 0
  }

  # Allow outbound HTTPS for updates
  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  # Allow outbound HTTP for updates
  egress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-private-nacl"
    Type = "security"
  })
}
