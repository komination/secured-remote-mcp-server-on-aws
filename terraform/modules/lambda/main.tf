module "lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.20.2"

  function_name = var.function_name

  handler = var.handler
  runtime = var.runtime
  publish = true

  layers = var.layers

  environment_variables = {
    for key, value in var.environment_variables : key => value
  }

  attach_policy_json = true
  policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = var.s3_bucket_arn
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = "${var.s3_bucket_arn}/*"
      }
    ]
  })

  create_package = false
  s3_existing_package = {
    bucket = var.s3_bucket_name
    key    = var.s3_key
  }

  vpc_subnet_ids         = var.vpc_subnet_ids
  vpc_security_group_ids = [var.vpc_security_group_id]

  attach_network_policy = true

  ignore_source_code_hash = true
}