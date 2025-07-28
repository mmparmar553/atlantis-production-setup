#!/bin/bash

# =============================================================================
# Atlantis Enterprise Startup Script
# =============================================================================
# Purpose: Start Atlantis server with enterprise configuration
# Author: Senior SRE Team
# Usage: ./scripts/start-atlantis.sh [environment]
# =============================================================================

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ATLANTIS_DIR="$PROJECT_ROOT/atlantis/server"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Logging functions
log() { echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"; }
info() { echo -e "${BLUE}[INFO] $1${NC}"; }
warn() { echo -e "${YELLOW}[WARN] $1${NC}"; }
error() { echo -e "${RED}[ERROR] $1${NC}"; exit 1; }

# Function to check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        error "Docker is required but not installed"
    fi
    
    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        error "Docker Compose is required but not installed"
    fi
    
    # Check if .env file exists
    if [[ ! -f "$ATLANTIS_DIR/.env" ]]; then
        warn ".env file not found. Creating from template..."
        if [[ -f "$ATLANTIS_DIR/.env.template" ]]; then
            cp "$ATLANTIS_DIR/.env.template" "$ATLANTIS_DIR/.env"
            error "Please edit $ATLANTIS_DIR/.env with your configuration before running again"
        else
            error ".env.template file not found"
        fi
    fi
    
    info "Prerequisites check passed"
}

# Function to validate configuration
validate_config() {
    log "Validating Atlantis configuration..."
    
    # Source environment variables
    source "$ATLANTIS_DIR/.env"
    
    # Check required variables
    local required_vars=(
        "ATLANTIS_GH_USER"
        "ATLANTIS_GH_TOKEN"
        "AWS_ACCESS_KEY_ID"
        "AWS_SECRET_ACCESS_KEY"
    )
    
    for var in "${required_vars[@]}"; do
        if [[ -z "${!var}" ]]; then
            error "Required environment variable $var is not set in .env file"
        fi
    done
    
    info "Configuration validation passed"
}

# Function to start Atlantis server
start_atlantis() {
    log "Starting Atlantis Enterprise Server..."
    
    cd "$ATLANTIS_DIR"
    
    # Pull latest image
    info "Pulling latest Atlantis image..."
    docker-compose pull
    
    # Start services
    info "Starting Atlantis services..."
    docker-compose up -d
    
    # Wait for health check
    info "Waiting for Atlantis to be healthy..."
    local max_attempts=30
    local attempt=1
    
    while [[ $attempt -le $max_attempts ]]; do
        if curl -f http://localhost:4141/healthz &> /dev/null; then
            log "✅ Atlantis is healthy and ready!"
            break
        fi
        
        if [[ $attempt -eq $max_attempts ]]; then
            error "Atlantis failed to start after $max_attempts attempts"
        fi
        
        info "Attempt $attempt/$max_attempts - waiting for Atlantis..."
        sleep 5
        ((attempt++))
    done
}

# Function to show status
show_status() {
    log "Atlantis Server Status"
    
    cd "$ATLANTIS_DIR"
    docker-compose ps
    
    echo ""
    info "Atlantis Web UI: http://localhost:4141"
    info "Health Check: http://localhost:4141/healthz"
    info "Logs: docker-compose logs -f atlantis"
}

# Function to show logs
show_logs() {
    log "Showing Atlantis logs..."
    cd "$ATLANTIS_DIR"
    docker-compose logs -f atlantis
}

# Function to stop Atlantis
stop_atlantis() {
    log "Stopping Atlantis Enterprise Server..."
    cd "$ATLANTIS_DIR"
    docker-compose down
    info "Atlantis stopped"
}

# Function to restart Atlantis
restart_atlantis() {
    log "Restarting Atlantis Enterprise Server..."
    stop_atlantis
    sleep 2
    start_atlantis
}

# Function to show help
show_help() {
    echo -e "${GREEN}Atlantis Enterprise Startup Script${NC}"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  start     - Start Atlantis server (default)"
    echo "  stop      - Stop Atlantis server"
    echo "  restart   - Restart Atlantis server"
    echo "  status    - Show server status"
    echo "  logs      - Show server logs"
    echo "  help      - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 start"
    echo "  $0 logs"
    echo "  $0 restart"
}

# Main execution
main() {
    local command="${1:-start}"
    
    case "$command" in
        "start")
            check_prerequisites
            validate_config
            start_atlantis
            show_status
            ;;
        "stop")
            stop_atlantis
            ;;
        "restart")
            restart_atlantis
            show_status
            ;;
        "status")
            show_status
            ;;
        "logs")
            show_logs
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        *)
            error "Unknown command: $command. Use '$0 help' for usage information."
            ;;
    esac
}

# Execute main function
main "$@"
