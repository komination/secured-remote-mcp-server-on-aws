// Outputs for Lambda Layer module

output "layer_arn" {
  description = "作成したLambda LayerのARN"
  value       = module.lambda_layer_s3.lambda_layer_arn
}