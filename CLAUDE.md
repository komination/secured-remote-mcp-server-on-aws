# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a secured MCP (Model Context Protocol) server deployed on AWS with OAuth authentication. The architecture uses:
- API Gateway (HTTP) with OAuth2 authentication as the entry point
- Private Lambda functions deployed within VPC for security
- S3 bucket access through VPC endpoints
- FastMCP framework for implementing the MCP server

Key architectural points:
- The Lambda function runs inside a private VPC subnet with no internet access
- S3 access is through VPC endpoints to maintain isolation
- Authentication is handled by AWS Cognito with OAuth2 client credentials flow
- The system is designed for production deployment with dev/prod environment separation

## Common Commands

### Terraform Operations
```bash
# Initialize Terraform (run from specific environment directory)
cd /app/terraform/env/dev && terraform init

# Plan Terraform changes (runs remotely on HCP Terraform)
just tf-plan

# Apply Terraform changes
cd /app/terraform/env/dev && terraform apply
```

### Python Development
```bash
# Export requirements from uv to requirements.txt
just pip-export

# Run the MCP server locally (from src directory)
cd /app/src && python main.py
```

### Testing API Connectivity
```bash
# Get OAuth token from AWS Secrets Manager (defaults to "admin" AWS profile)
just get-token "secret-name" "aws-profile"

# Test full API connectivity (token + API call)
just test-api "secret-name" "https://api-endpoint.execute-api.ap-northeast-1.amazonaws.com/mcp/" "aws-profile"
```

### GitHub Operations
```bash
# Create a pull request using GitHub CLI
just pr-create "head_branch" "base_branch" "title"
```

### Linting and Validation
```bash
# Pre-commit hooks (Terraform formatting and validation)
pre-commit run --all-files

# Terraform specific checks
terraform fmt -recursive terraform/
terraform validate
```

## Code Architecture

### Directory Organization
- `/terraform/modules/` - Reusable Terraform modules for AWS resources
- `/terraform/env/` - Environment-specific configurations (dev/prod)
- `/src/` - Python MCP server implementation using FastMCP
- `/sam/` - AWS SAM implementation (incomplete, ignore per copilot-instructions.md)

### Key Components
1. **MCP Server** (`src/main.py`): FastMCP-based server exposing tools:
   - `list_files`: Lists S3 objects with prefix filtering (optional `bucket` parameter, defaults to `BUCKET_NAME` env var)
   - `add`, `multiply`: Example calculation tools
   - Local development URL: `http://127.0.0.1:8080/mcp`
   - Configured for stateless HTTP with JSON responses

2. **Infrastructure Modules**:
   - `vpc`: Creates isolated network with private subnets
   - `lambda`: Deploys the MCP server as Lambda function
   - `api_gateway`: Exposes Lambda with OAuth authentication
   - `cognito`: Manages OAuth2 authentication
   - `vpc_endpoint_*`: Enables private access to AWS services

### Environment Variables
The Lambda function expects:
- `BUCKET_NAME`: S3 bucket for file operations

### Authentication Flow
1. Client obtains OAuth token from Cognito using client credentials
2. Token is included in API Gateway requests as Bearer token
3. API Gateway validates token and forwards to Lambda
4. Lambda executes MCP operations within VPC

## Development Workflow

1. **Infrastructure Changes**: Modify Terraform modules or environment configs, then run `terraform plan` to preview
2. **MCP Server Changes**: Update `src/main.py`, test locally, then export requirements with `just pip-export`
3. **Deployment**: Use HCP Terraform for remote state management and deployment
4. **Testing**: Use `just test-api` to verify end-to-end connectivity after deployment

## Important Notes

- The project uses HCP Terraform for remote state management
- AWS profiles are required for local AWS CLI operations (default: "admin")
- Pre-commit hooks ensure Terraform code quality
- The SAM directory should be ignored (it's an incomplete comparison implementation)
- Architecture diagram available at `/app/architecture.png`

## VS Code MCP Client Configuration

Example configuration for VS Code MCP extension (mcp.json):
```json
{
  "name": "secured-mcp-on-aws",
  "description": "Secured MCP Server on AWS",
  "url": "https://your-api-endpoint.execute-api.ap-northeast-1.amazonaws.com/mcp/",
  "apiKey": "Bearer YOUR_OAUTH_TOKEN",
  "customHeaders": {
    "Content-Type": "application/json"
  }
}
```

## Terraform Outputs

Key outputs after deployment:
- `api_gateway_endpoint`: API endpoint URL for MCP server access
- `cognito_client_secret_name`: AWS Secrets Manager secret containing OAuth credentials
- `lambda_function_name`: Name of the deployed Lambda function
- `lambda_layer_arn`: ARN of Lambda layer with Python dependencies

Access outputs: `cd /app/terraform/env/dev && terraform output`

## CI/CD Pipeline

GitHub Actions workflow (`/.github/workflows/deploy.yml`):
- **Trigger**: On PR close to develop branch
- **Authentication**: OIDC (no stored AWS credentials)
- **Process**: Builds Lambda artifacts → Uploads to S3 → Triggers HCP Terraform run
- **Security**: Uses least-privilege IAM role with resource-scoped permissions

## Python Dependencies

- **Python Version**: 3.13+
- **Package Manager**: uv (fast Python package manager)
- **Key Dependencies**:
  - FastMCP 2.3.5+ (MCP framework)
  - boto3 (AWS SDK)
  - uvicorn (ASGI server for local development)
- **Dependency Management**: Use `just pip-export` to sync uv.lock to requirements.txt

## IAM Security

The project implements minimal IAM permissions following the principle of least privilege:

### HCP Terraform Role
- **Custom Policy**: `hcp-terraform-policy-${repo_name}`
- **Permissions**: Only services used by Terraform modules (API Gateway, Lambda, S3, VPC, Cognito, Secrets Manager, limited IAM)
- **Replaces**: AdministratorAccess (previous over-privileged access)

### GitHub Actions Role
- **Custom Policy**: `github-actions-policy-${repo_name}`
- **Permissions**: Limited to CI/CD operations (S3 artifact upload/download, Lambda function updates)
- **Resource Scope**: Only resources matching the repository name pattern
- **Replaces**: AdministratorAccess (previous over-privileged access)

This security enhancement significantly reduces the attack surface while maintaining full functionality.