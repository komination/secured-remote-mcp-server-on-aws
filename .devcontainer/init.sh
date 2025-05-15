#!/bin/bash
mkdir -p ~/.aws

# 許可セットなど、アクセス割り当てに準じたプロファイルを作成
cat <<EOL > ~/.aws/config
[default]
region=${AWS_DEFAULT_REGION}
output=${AWS_DEFAULT_OUTPUT}

[profile ${SSO_PROFILE_NAME}]
sso_session = ${SSO_PROFILE_NAME}
sso_account_id = ${SSO_ACCOUNT_ID}
sso_role_name = ${SSO_ROLE_NAME}
region = ${AWS_DEFAULT_REGION}

[sso-session ${SSO_PROFILE_NAME}]
sso_start_url = ${SSO_START_URL}
sso_region = ${AWS_DEFAULT_REGION}
sso_registration_scopes = sso:account:access
EOL

echo "AWS config file created successfully at ~/.aws/config"