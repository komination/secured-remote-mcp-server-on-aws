data "aws_region" "current" {}

module "lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.20.2"

  function_name = var.function_name

  handler       = var.handler
  runtime       = var.runtime
  publish       = true
  architectures = ["x86_64"]
  timeout       = var.timeout
  memory_size   = var.memory_size

  layers = concat(
    [
      "arn:aws:lambda:${data.aws_region.current.name}:753240598075:layer:LambdaAdapterLayerX86:25",
      "arn:aws:serverlessrepo:${data.aws_region.current.name}:057560766410:applications/aws-lambda-powertools-python-layer-v3-python313-x86-64"
    ],
    var.layers,
  )

  environment_variables = merge(
    var.environment_variables,
    {
      PYTHONPATH              = "/opt/python"
      AWS_LAMBDA_EXEC_WRAPPER = "/opt/bootstrap"
      AWS_LWA_ALLOW_METHODS   = "DELETE,PUT,PATCH"
      PORT                    = "8080"
    }
  )

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

  reserved_concurrent_executions = var.reserved_concurrent_executions
}