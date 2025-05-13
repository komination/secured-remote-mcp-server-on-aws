data "archive_file" "lambda_layer_zip" {
  count = local.is_dummy_deploy ? 1 : 0
  type        = "zip"
  source_dir  = "${path.module}/dummy"
  output_path = "${path.module}/.terraform-artifacts/layer.zip"
  excludes = [
    "*.pyc",
    "__pycache__/**",
    "*.toml",
    "*.lock",
    ".venv/**",
  ]
}

data "archive_file" "lambda_zip" {
  count = local.is_dummy_deploy ? 1 : 0
  type        = "zip"
  source_dir  = "${path.module}/../../../src"
  output_path = "${path.module}/.terraform-artifacts/lambda.zip"
  excludes = [
    "*.pyc",
    "__pycache__/**",
    "*.toml",
    "*.lock",
    "layer/**",
    ".venv/**",
    "requirements.txt",
  ]
}

resource "aws_s3_object" "lambda_layer_archive" {
  count  = local.is_dummy_deploy ? 1 : 0

  bucket = module.s3.bucket_id
  key    = var.lambda_layer_zip_key

  source = data.archive_file.lambda_layer_zip[count.index].output_path

  depends_on = [
    module.s3
  ]
}

resource "aws_s3_object" "lambda_archive" {
  count  = local.is_dummy_deploy ? 1 : 0

  bucket = module.s3.bucket_id
  key    = var.lambda_zip_key

  source = data.archive_file.lambda_zip[count.index].output_path

  depends_on = [
    module.s3
  ]
}