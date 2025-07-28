# 🚀 Atlantis Server Setup Guide

## Overview
This guide walks through setting up a production-ready Atlantis server for enterprise infrastructure management.

## Prerequisites

### Required Tools
- Docker or Kubernetes cluster
- GitHub account with admin access to repositories
- AWS account with appropriate permissions
- Domain name for webhook endpoints (optional but recommended)

### Required Permissions

#### GitHub Permissions
- Repository admin access
- Ability to create webhooks
- Personal Access Token with repo permissions

#### AWS Permissions
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "s3:*",
        "iam:*",
        "cloudwatch:*",
        "logs:*"
      ],
      "Resource": "*"
    }
  ]
}
```

## Setup Methods

### Method 1: Docker Compose (Recommended for Development)

#### Step 1: Configure Environment Variables
```bash
cd atlantis/server
cp .env.template .env
# Edit .env with your values
```

#### Step 2: Start Atlantis Server
```bash
docker-compose up -d
```

#### Step 3: Configure GitHub Webhook
1. Go to your repository settings
2. Add webhook: `http://your-atlantis-server:4141/events`
3. Select "Pull requests" and "Issue comments" events
4. Add webhook secret from your .env file

### Method 2: Kubernetes Deployment (Production)

#### Step 1: Create Namespace
```bash
kubectl create namespace atlantis
```

#### Step 2: Create Secrets
```bash
kubectl create secret generic atlantis-secrets \
  --from-literal=github-token=your-token \
  --from-literal=github-webhook-secret=your-secret \
  --from-literal=aws-access-key-id=your-key \
  --from-literal=aws-secret-access-key=your-secret \
  -n atlantis
```

#### Step 3: Deploy Atlantis
```bash
kubectl apply -f atlantis/server/kubernetes/ -n atlantis
```

## Configuration

### Atlantis Configuration
The `atlantis.yaml` file defines:
- **Projects**: Different environments (dev, staging, prod)
- **Workflows**: Security validation steps
- **Requirements**: Approval and merge requirements

### Security Features
- **Branch Protection**: Prevents direct pushes
- **Required Approvals**: Peer review mandatory
- **Security Scanning**: Automated policy checks
- **Audit Logging**: Complete change tracking

## Testing the Setup

### Step 1: Create Test PR
```bash
# Make a small change
echo "# Test" >> README.md
git add README.md
git commit -m "test: Atlantis setup verification"
git push origin test-branch

# Create PR
gh pr create --title "Test Atlantis Setup" --body "Testing Atlantis automation"
```

### Step 2: Verify Atlantis Response
- Atlantis should automatically comment with `terraform plan`
- Plan output should show infrastructure changes
- Security validation should pass

### Step 3: Test Apply Process
```bash
# Comment on PR
atlantis apply
```

### Step 4: Verify Infrastructure
- Check AWS console for created resources
- Verify security groups and S3 buckets
- Confirm all security controls are active

## Troubleshooting

### Common Issues

#### Atlantis Not Responding to PRs
- Check webhook configuration
- Verify GitHub token permissions
- Check Atlantis server logs: `docker-compose logs atlantis`

#### Terraform Apply Failures
- Verify AWS credentials
- Check IAM permissions
- Review Terraform state conflicts

#### Security Validation Failures
- Review security group rules
- Check S3 bucket policies
- Verify encryption settings

### Logs and Monitoring

#### View Atlantis Logs
```bash
# Docker
docker-compose logs -f atlantis

# Kubernetes
kubectl logs -f deployment/atlantis -n atlantis
```

#### Monitor Infrastructure
- CloudWatch for AWS resources
- VPC Flow Logs for network monitoring
- S3 access logs for storage monitoring

## Security Best Practices

### Server Security
- Use HTTPS for webhook endpoints
- Rotate GitHub tokens regularly
- Use IAM roles instead of access keys when possible
- Enable audit logging

### Infrastructure Security
- All S3 buckets have encryption enabled
- Security groups follow least privilege
- VPC Flow Logs enabled for monitoring
- Network ACLs provide additional security layer

### Operational Security
- All changes require peer review
- Production changes need senior approval
- Complete audit trail maintained
- Automated security scanning

## Maintenance

### Regular Tasks
- Update Atlantis server image
- Rotate credentials
- Review security policies
- Monitor resource usage

### Backup and Recovery
- Terraform state stored in S3 with versioning
- Configuration files in Git
- Database backups (if using external database)

## Support

### Getting Help
- Check Atlantis documentation: https://www.runatlantis.io/
- Review GitHub issues and discussions
- Contact SRE team for enterprise support

### Reporting Issues
- Include Atlantis logs
- Provide Terraform configuration
- Describe expected vs actual behavior
- Include steps to reproduce
