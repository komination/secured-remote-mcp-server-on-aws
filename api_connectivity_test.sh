#!/usr/bin/env bash
set -euo pipefail

# Check arguments
if [ $# -lt 2 ]; then
    echo "Usage: $0 <secret-name> <api-endpoint> [aws-profile]"
    exit 1
fi

SECRET_NAME="$1"
API_ENDPOINT="$2"
AWS_PROFILE="${3:-admin}"

# Get credentials from Secrets Manager
read -r CLIENT_ID CLIENT_SECRET DOMAIN SCOPE <<<"$(AWS_PROFILE="$AWS_PROFILE" aws secretsmanager get-secret-value \
  --secret-id "$SECRET_NAME" \
  --query 'SecretString' --output text \
  | jq -r '[.client_id,.client_secret,.domain,.scope] | @tsv')"

# Get OAuth token
TOKEN=$(curl -s -u "${CLIENT_ID}:${CLIENT_SECRET}" \
  -d grant_type=client_credentials -d scope="$SCOPE" \
  "${DOMAIN}/oauth2/token" | jq -r .access_token)

# Call API
curl -i -H "Authorization: Bearer $TOKEN" "$API_ENDPOINT"