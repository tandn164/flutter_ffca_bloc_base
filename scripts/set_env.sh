#!/bin/bash

# Script to switch between environments
# Usage: ./scripts/set_env.sh <environment>
# Environments: development, staging, production

ENVIRONMENT=${1:-development}

if [ ! -f ".env.$ENVIRONMENT" ]; then
    echo "❌ Environment file .env.$ENVIRONMENT not found!"
    echo "Available environments:"
    ls .env.* 2>/dev/null | sed 's/.env./- /' || echo "No environment files found"
    exit 1
fi

# Copy environment file to .env
cp ".env.$ENVIRONMENT" ".env"

echo "✅ Environment set to: $ENVIRONMENT"
echo "📄 Active configuration:"
echo "========================="
cat ".env"
echo "========================="
