# 🏢 Enterprise Atlantis Production Setup

## Overview
This repository demonstrates a **production-ready Atlantis deployment** with enterprise-grade security, compliance, and automation features for managing AWS infrastructure across multiple environments.

## 🏗️ Repository Structure

```
atlantis-production-setup/
├── environments/
│   ├── dev/                    # Development environment
│   ├── staging/                # Staging environment
│   └── prod/                   # Production environment
├── modules/
│   ├── vpc/                    # Reusable VPC module
│   ├── s3/                     # Reusable S3 module
│   └── security/               # Security-focused modules
├── atlantis/
│   ├── server/                 # Atlantis server configuration
│   └── config/                 # Atlantis configuration files
├── docs/                       # Documentation
├── scripts/                    # Automation scripts
├── .github/workflows/          # CI/CD workflows
└── atlantis.yaml              # Main Atlantis configuration
```

## 🔒 Enterprise Security Features

### **Multi-Environment Protection**
- **Development**: Standard security validation
- **Staging**: Enhanced security checks
- **Production**: Maximum security with senior approval

### **Security Workflows**
- **Terraform Format Validation**: Ensures code consistency
- **Security Policy Scanning**: Automated security checks
- **Cost Impact Analysis**: Financial impact assessment
- **Compliance Reporting**: Audit trail generation

### **Access Controls**
- **Branch Protection**: Prevents direct pushes to main
- **Required Approvals**: Peer review mandatory
- **Environment Isolation**: Separate approval workflows
- **Audit Logging**: Complete change tracking

## 🚀 Atlantis Server Setup

### **Prerequisites**
- Docker or Kubernetes cluster
- GitHub App or Personal Access Token
- AWS credentials with appropriate permissions
- Domain name for webhook endpoints

### **Quick Start with Docker**
```bash
# 1. Set environment variables
export ATLANTIS_GH_USER=your-github-username
export ATLANTIS_GH_TOKEN=your-github-token
export ATLANTIS_REPO_ALLOWLIST=github.com/your-org/*

# 2. Run Atlantis server
docker run -it --rm \
  -p 4141:4141 \
  -e ATLANTIS_GH_USER=$ATLANTIS_GH_USER \
  -e ATLANTIS_GH_TOKEN=$ATLANTIS_GH_TOKEN \
  -e ATLANTIS_REPO_ALLOWLIST=$ATLANTIS_REPO_ALLOWLIST \
  -e ATLANTIS_ATLANTIS_URL=https://your-atlantis-domain.com \
  -v $(pwd):/atlantis-data \
  runatlantis/atlantis:latest server
```

### **Enterprise Kubernetes Deployment**
```bash
# Deploy to Kubernetes with enterprise features
kubectl apply -f atlantis/server/kubernetes/
```

## 🔄 Workflow Process

### **1. Development Workflow**
```bash
# Create feature branch
git checkout -b feature/add-s3-bucket

# Make infrastructure changes
# ... edit Terraform files ...

# Push and create PR
git push origin feature/add-s3-bucket
gh pr create --title "Add S3 Bucket" --body "Description"

# Atlantis automatically:
# - Runs terraform plan
# - Posts plan to PR
# - Waits for approval

# After approval:
# Comment: atlantis apply
# Atlantis automatically deploys
```

### **2. Production Workflow**
```bash
# Production changes require:
# - Senior engineer approval
# - Enhanced security validation
# - Stakeholder notification
# - Compliance documentation
```

## 🛡️ Security Best Practices

### **Infrastructure Security**
- All S3 buckets have encryption enabled
- VPCs use private subnets by default
- Security groups follow least privilege
- IAM roles use minimal permissions

### **Operational Security**
- All changes require peer review
- Production changes need senior approval
- Complete audit trail maintained
- Automated security scanning

### **Compliance Features**
- Change tracking and documentation
- Cost impact analysis
- Security policy validation
- Stakeholder notifications

## 📚 Documentation

- [Atlantis Server Setup](docs/atlantis-setup.md)
- [Security Policies](docs/security-policies.md)
- [Troubleshooting Guide](docs/troubleshooting.md)
- [Best Practices](docs/best-practices.md)

## 🎯 Learning Objectives

This setup demonstrates:
- **Real Atlantis automation** with webhooks
- **Enterprise security controls** and approvals
- **Multi-environment management** with different policies
- **Production-ready infrastructure** patterns
- **Compliance and audit** capabilities

## 🚀 Getting Started

1. **Clone Repository**: `git clone https://github.com/mmparmar553/atlantis-production-setup.git`
2. **Set Up Atlantis Server**: Follow [setup guide](docs/atlantis-setup.md)
3. **Configure GitHub Webhooks**: Point to your Atlantis server
4. **Create First PR**: Test the workflow with a simple change
5. **Deploy Infrastructure**: Use `atlantis apply` after approval

## 🤝 Contributing

1. Create feature branch
2. Make infrastructure changes
3. Test in development environment
4. Create pull request with detailed description
5. Wait for Atlantis plan and security review
6. Get approval from designated reviewers
7. Apply changes with `atlantis apply`
8. Merge after successful deployment

---

**This is a production-ready Atlantis setup that demonstrates enterprise-grade infrastructure management with real automation, security, and compliance features.** 🏢✨
