cd /app/terraform/env/dev

# 既存の .terraform フォルダを削除
rm -rf .terraform

# Terraform 初期化
terraform init \
  -backend-config="bucket=${TFSTATE_BUCKET_NAME}" \
  -backend-config="key=${TFSTATE_BUCKET_KEY}" \
  -backend-config="region=${TFSTATE_BUCKET_REGION}"