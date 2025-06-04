tf-init:
    cd /app/terraform/env/dev && \
    terraform init

# remote run
tf-plan:
    cd /app/terraform/env/dev && \
    terraform plan

# for aws sam cli
build-lambda-zip:
    cd /app/src && \
    zip -r /app/sam/lambda.zip . -x "requirements.txt" "pyproject.toml" "deps/*"

# for aws sam cli
build-layer-zip:
    cd /app/src && \
    python -m pip install --upgrade -r "requirements.txt" --target "./deps" && \
    cd ./deps && \
    zip -r /app/sam/layer.zip .


# Get OAuth token from AWS Secrets Manager
get-token secret_name aws_profile="admin":
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Getting credentials from Secrets Manager..."
    
    read -r CLIENT_ID CLIENT_SECRET DOMAIN SCOPE <<<"$(AWS_PROFILE="{{aws_profile}}" aws secretsmanager get-secret-value \
      --secret-id "{{secret_name}}" \
      --query 'SecretString' --output text \
      | jq -r '[.client_id,.client_secret,.domain,.scope] | @tsv')"
    
    echo "Requesting OAuth token..."
    TOKEN=$(curl -s -u "${CLIENT_ID}:${CLIENT_SECRET}" \
      -d grant_type=client_credentials -d scope="$SCOPE" \
      "${DOMAIN}/oauth2/token" | jq -r .access_token)
    
    if [ "$TOKEN" = "null" ] || [ -z "$TOKEN" ]; then
        echo "Error: Failed to get access token"
        exit 1
    fi
    
    echo "Access token obtained successfully: ${TOKEN:0:20}..."

# Test API connectivity with OAuth token
test-api secret_name api_endpoint aws_profile="admin":
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Testing API connectivity..."
    echo "Secret: {{secret_name}}"
    echo "Endpoint: {{api_endpoint}}"
    echo "AWS Profile: {{aws_profile}}"
    echo
    
    echo "Getting credentials from Secrets Manager..."
    read -r CLIENT_ID CLIENT_SECRET DOMAIN SCOPE <<<"$(AWS_PROFILE="{{aws_profile}}" aws secretsmanager get-secret-value \
      --secret-id "{{secret_name}}" \
      --query 'SecretString' --output text \
      | jq -r '[.client_id,.client_secret,.domain,.scope] | @tsv')"
    
    echo "Requesting OAuth token..."
    TOKEN=$(curl -s -u "${CLIENT_ID}:${CLIENT_SECRET}" \
      -d grant_type=client_credentials -d scope="$SCOPE" \
      "${DOMAIN}/oauth2/token" | jq -r .access_token)
    
    if [ "$TOKEN" = "null" ] || [ -z "$TOKEN" ]; then
        echo "Error: Failed to get access token"
        exit 1
    fi
    
    echo "Token obtained successfully. Testing API endpoint..."
    echo
    curl -i -H "Authorization: Bearer $TOKEN" "{{api_endpoint}}"

pr-create head_branch base_branch title:
    gh pr create \
        --base {{base_branch}} \
        --head {{head_branch}} \
        --title "{{title}}" \
        --body "" \
        --label ""

pip-export:
    cd /app/src && \
    uv export --format=requirements.txt --output-file requirements.txt --no-cache
