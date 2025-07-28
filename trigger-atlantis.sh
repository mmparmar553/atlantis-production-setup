#!/bin/bash

# Automated Atlantis Trigger Script
# This demonstrates real Atlantis automation

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"; }
info() { echo -e "${BLUE}[INFO] $1${NC}"; }

echo "🚀 Atlantis Enterprise Automation Demo"
echo "======================================"

# Function to trigger plan
trigger_plan() {
    log "Triggering automated Atlantis plan..."
    ./webhook-handler.sh issue_comment 2 feature/simple-s3-bucket opened "atlantis plan"
    echo ""
}

# Function to trigger apply
trigger_apply() {
    log "Triggering automated Atlantis apply..."
    ./webhook-handler.sh issue_comment 2 feature/simple-s3-bucket opened "atlantis apply"
    echo ""
}

# Function to show status
show_status() {
    log "Checking AWS S3 buckets created by Atlantis..."
    echo ""
    info "Atlantis-created S3 buckets:"
    aws s3api list-buckets --query 'Buckets[?contains(Name, `atlantis-simple`)].{Name:Name,Created:CreationDate}' --output table
    echo ""
}

# Function to show help
show_help() {
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  plan     - Trigger automated Atlantis plan"
    echo "  apply    - Trigger automated Atlantis apply"  
    echo "  status   - Show created AWS resources"
    echo "  demo     - Run complete demo (plan + apply + status)"
    echo "  help     - Show this help"
    echo ""
}

# Main execution
case "${1:-demo}" in
    "plan")
        trigger_plan
        ;;
    "apply")
        trigger_apply
        ;;
    "status")
        show_status
        ;;
    "demo")
        log "🎯 Running complete Atlantis automation demo..."
        echo ""
        trigger_plan
        sleep 2
        trigger_apply
        sleep 2
        show_status
        log "✅ Atlantis automation demo completed!"
        ;;
    "help"|"--help"|"-h")
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
