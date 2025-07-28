#!/bin/bash

# Simple Atlantis startup for demonstration
# This starts Atlantis with minimal configuration for testing

echo "🚀 Starting Atlantis Enterprise Demo Server..."

# Set required environment variables
export ATLANTIS_GH_USER=mmparmar553
export ATLANTIS_GH_TOKEN=demo-token-placeholder
export ATLANTIS_REPO_ALLOWLIST="github.com/mmparmar553/atlantis-production-setup"
export ATLANTIS_ATLANTIS_URL=http://localhost:4141

# Start Atlantis in demo mode (without real GitHub integration)
docker run -it --rm \
  -p 4141:4141 \
  -e ATLANTIS_GH_USER=$ATLANTIS_GH_USER \
  -e ATLANTIS_GH_TOKEN=$ATLANTIS_GH_TOKEN \
  -e ATLANTIS_REPO_ALLOWLIST="$ATLANTIS_REPO_ALLOWLIST" \
  -e ATLANTIS_ATLANTIS_URL=$ATLANTIS_ATLANTIS_URL \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  -e AWS_DEFAULT_REGION=us-west-2 \
  -v $(pwd):/atlantis-data \
  runatlantis/atlantis:latest server --gh-user=$ATLANTIS_GH_USER --gh-token=$ATLANTIS_GH_TOKEN --repo-allowlist="$ATLANTIS_REPO_ALLOWLIST"
