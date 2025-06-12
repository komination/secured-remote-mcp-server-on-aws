# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a secured MCP (Model Context Protocol) server deployed on AWS with OAuth authentication. The project provides a secure way to deploy MCP Server (Streamable HTTP) publicly while protecting it with access controls.

### Features

- MCP Server (Streamable HTTP) can be deployed publicly with access protection
- API Gateway entry point is protected by Cognito Authorizer with client authentication
- Declarative environment management with Terraform
- Automated deployment using GitHub Actions and HCP Terraform
- Unified development environment sharing through Devcontainers
- Utilizes Claude Code and GitHub Copilot, following latest practices with AWS official MCP Server

### Architecture

- API Gateway (HTTP) with OAuth2 authentication as the entry point
- Private Lambda functions deployed within VPC for security
- S3 bucket access through VPC endpoints
- FastMCP framework for implementing the MCP server

### Key Architectural Points

- The Lambda function runs inside a private VPC subnet with no internet access
- S3 access is through VPC endpoints to maintain isolation
- Authentication is handled by AWS Cognito with OAuth2 client credentials flow
- The system is designed for production deployment with dev/prod environment separation

Architecture diagram available at `/app/architecture.png`

## Directory Structure

```bash
├── /.devcontainer                     # VS Code Dev Container configuration
│   ├── api_connectivity_test.sh       # API connectivity test script
│   ├── devcontainer.json              
│   ├── dockerfile.devcontainer        
│   ├── github_deployments_delete.sh   # GitHub deployments cleanup script
│   └── init.sh                        # AWS SSO Profile initialization script for Devcontainer
├── /.github
│   ├── /workflows
│   │   ├── pr-closed-deploy-develop.yml             # Deploy on PR close to develop branch
│   │   ├── reusable-build-and-push.yml              
│   │   ├── reusable-plan-and-deploy-with-tfc.yml    # HCP Terraform run
│   │   ├── reusable-update-lambda.yml               # Lambda update process
│   │   └── reusable-validate-environment-secrets.yml # Environment variables validation
│   └── copilot-instructions.md        # GitHub Copilot custom instructions
├── /.vscode
│   ├── mcp.json                       # MCP Server connection configuration
│   └── settings.json                  
├── /terraform
│   ├── /env                           # Environment-specific configurations
│   │   ├── /dev                       # Development environment
│   │   │   ├── /dummy                 # Dummy files for initial Lambda deployment
│   │   │   ├── backend.tf             # Backend configuration
│   │   │   ├── providers.tf           # Provider configuration
│   │   │   ├── locals.tf              # Local values
│   │   │   ├── main.tf                # Resource definitions
│   │   │   ├── dummy.tf               # Dummy zip creation
│   │   │   ├── outputs.tf             # Outputs for HCP Terraform
│   │   │   ├── terraform.tf           # Terraform version constraints
│   │   │   └── variables.tf           # Variable definitions
│   │   └── /prod                      # Production environment (same structure)
│   └── /modules                       # Reusable modules
│       ├── /api_gateway               
│       ├── /cognito                   
│       ├── /lambda                    
│       ├── /lambda_layer              
│       ├── /s3                        
│       ├── /vpc                       
│       ├── /vpc_endpoint_lambda       
│       └── /vpc_endpoint_s3           
├── /sam                               # AWS SAM implementation (incomplete, for comparison only)
│   ├── samconfig.toml
│   └── template.yaml
├── /src                               # MCP Server application
│   ├── main.py                        # FastMCP implementation
│   ├── pyproject.toml                 # Python project configuration
│   ├── requirements.txt               # pip dependencies
│   ├── run.sh                         # Startup script
│   └── uv.lock                        
├── .auto.tfvars.sample                # HCP Terraform variables sample
├── .env.sample                        # Environment variables sample
├── .gitignore
├── .pre-commit-config.yaml            
├── .terraform-version                 # Terraform version (1.12.1)
├── architecture.png                   # Architecture diagram
├── bootstrap.tf                       # HCP Terraform & OIDC initial setup
├── CLAUDE.md                          # Claude Code project instructions
├── compose.yml                        # Docker Compose configuration for Devcontainer
├── justfile                           # Task runner definitions
└── README.md
```

## Environment Setup

### Prerequisites

- Devcontainer execution environment (VS Code recommended)
- HCP Terraform account (with GitHub account integration)
- AWS IAM Identity Center user account

### Initial Setup

1. **Create configuration files from samples:**

```bash
cp .env.sample .env
cp .auto.tfvars.sample .auto.tfvars
```

2. **HCP Terraform Bootstrap:**

- Generate `TFE_TOKEN` at `https://app.terraform.io/app/settings/tokens`
- Create `TFE_ORGANIZATION` at `https://app.terraform.io/app/organizations/new`
- Create HCP Terraform workspaces:

```bash
# Inside devcontainer, run:
/app$ terraform init
/app$ terraform plan
/app$ terraform apply

# This creates the following structure in HCP Terraform:
YOUR_ORGANIZATION/
├── projects/
    └── secured-remote-mcp-server-on-aws/
        └── workspaces/
            ├── dev-secured-remote-mcp-server-on-aws
            └── prod-secured-remote-mcp-server-on-aws
```

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
# Get OAuth token from AWS Secrets Manager
# Example: Get token for dev environment using "admin" AWS profile
just get-token "dev-cognito-client-secret" "admin"

# Test full API connectivity (token + API call)
# Example: Test dev API endpoint
just test-api "dev-cognito-client-secret" "https://abc123.execute-api.ap-northeast-1.amazonaws.com/mcp/" "admin"

# The test script will:
# 1. Retrieve OAuth credentials from AWS Secrets Manager
# 2. Request an access token from Cognito
# 3. Make a test call to the API endpoint
# 4. Display the response
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
  - Each environment contains:
    - `backend.tf` - Backend configuration for HCP Terraform
    - `providers.tf` - AWS provider configuration
    - `locals.tf` - Local values and common configurations
    - `main.tf` - Resource definitions using modules
    - `terraform.tf` - Terraform version constraints
    - `variables.tf` - Variable definitions
    - `outputs.tf` - Output values
    - `dummy.tf` - Initial Lambda deployment dummy file creation
    - `common_tags.tfvars` - Common resource tags
- `/src/` - Python MCP server implementation using FastMCP
- `/sam/` - AWS SAM implementation (incomplete, ignore per copilot-instructions.md)
- `/.devcontainer/` - Development container configuration
  - `api_connectivity_test.sh` - Standalone script to test API connectivity
  - `github_deployments_delete.sh` - Clean up GitHub deployment history
  - `init.sh` - Initialize AWS SSO profile inside devcontainer

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

### API Gateway Limitations

**Important**: API Gateway does not support Server-Sent Events (SSE) or HTTP streaming responses. All results must be buffered and returned at once. This is why the MCP server configuration requires:

```python
from fastmcp import FastMCP

mcp = FastMCP(
    "remote-mcp-server",
    stateless_http=True,
    json_response=True  # Required for complete JSON response in one request
)
```

### Environment Variables
The Lambda function expects:
- `BUCKET_NAME`: S3 bucket for file operations

### Authentication Flow
1. Client obtains OAuth token from Cognito using client credentials
2. Token is included in API Gateway requests as Bearer token
3. API Gateway validates token and forwards to Lambda
4. Lambda executes MCP operations within VPC

## Development Workflow

1. **Setup Environment**:
   - Create `.env` and `.auto.tfvars` from sample files
   - Run devcontainer initialization: `.devcontainer/init.sh`
   - Configure AWS SSO profile

2. **Infrastructure Changes**:
   - Modify Terraform modules or environment configs
   - Run `terraform plan` from environment directory to preview changes
   - Apply changes through HCP Terraform

3. **MCP Server Changes**:
   - Update `src/main.py` with new tools or modifications
   - Test locally: `cd /app/src && python main.py`
   - Export requirements: `just pip-export`
   - Commit changes to trigger CI/CD pipeline

4. **Deployment**:
   - Create PR to develop branch
   - GitHub Actions builds Lambda package on PR close
   - HCP Terraform applies infrastructure changes
   - Lambda function is updated automatically

5. **Testing**:
   - Obtain OAuth token: `just get-token "secret-name" "profile"`
   - Test API endpoint: `just test-api "secret-name" "api-url" "profile"`
   - Verify CloudWatch logs for Lambda execution

## Important Notes

- The project uses HCP Terraform for remote state management
- AWS profiles are required for local AWS CLI operations (default: "admin")
- Pre-commit hooks ensure Terraform code quality
- The SAM directory (`/sam`) should be ignored (it's an incomplete comparison implementation)
- API Gateway does not support streaming responses - all data must be returned at once
- Lambda functions run in private VPC with no internet access
- Architecture diagram available at `/app/architecture.png`
- Always run commands from within the devcontainer for consistency
- OAuth tokens expire after 1 hour and need to be refreshed

## MCP Client Configuration

### VS Code MCP Extension

Example configuration for VS Code MCP extension (`.vscode/mcp.json`):

```json
{
  "servers": {
    "secured-mcp-on-aws": {
      "type": "http",
      "url": "https://abc123.execute-api.ap-northeast-1.amazonaws.com/mcp/",
      "headers": {
        "Authorization": "Bearer YOUR_OAUTH_TOKEN",
        "Accept": "application/json"
      }
    }
  }
}
```

### GitHub Copilot Agent

For GitHub Copilot Agent integration, use the same configuration format in your MCP settings.

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
