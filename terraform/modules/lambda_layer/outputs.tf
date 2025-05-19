// Outputs for Lambda Layer module

output "layer_arn" {
  description = "作成したLambda LayerのARN"
  value       = module.lambda_layer_s3.lambda_layer_arn
}

output "layer_name" {
  description = "作成したLambda Layerの名前"
  value       = module.lambda_layer_s3.lambda_function_name
}