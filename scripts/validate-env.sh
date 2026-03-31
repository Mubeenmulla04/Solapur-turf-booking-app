#!/bin/bash

# Environment Variables Validation Script

echo "Validating environment variables..."

required_vars=(
  "DB_HOST"
  "DB_USERNAME"
  "DB_PASSWORD"
  "DB_DATABASE"
  "JWT_SECRET"
  "RAZORPAY_KEY_ID"
  "RAZORPAY_KEY_SECRET"
  "RAZORPAY_WEBHOOK_SECRET"
)

missing_vars=()

# Load .env file if exists
if [ -f .env ]; then
  export $(cat .env | grep -v '^#' | xargs)
fi

for var in "${required_vars[@]}"; do
  if [ -z "${!var}" ]; then
    missing_vars+=("$var")
  fi
done

if [ ${#missing_vars[@]} -ne 0 ]; then
  echo "❌ Error: Missing required environment variables:"
  printf '  - %s\n' "${missing_vars[@]}"
  exit 1
fi

# Validate JWT secret length
if [ ${#JWT_SECRET} -lt 32 ]; then
  echo "❌ Error: JWT_SECRET must be at least 32 characters long"
  exit 1
fi

# Validate database connection
if ! PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USERNAME -d $DB_DATABASE -c "SELECT 1" > /dev/null 2>&1; then
  echo "❌ Error: Cannot connect to database"
  exit 1
fi

echo "✅ All required environment variables are set and valid!"

