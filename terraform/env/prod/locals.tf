locals {
  is_dummy_deploy = (
    var.lambda_zip_key == "lambda/prod-my-lambda-fn-dummy.zip" &&
    var.lambda_layer_zip_key == "lambda-layers/prod-my-lambda-layer-dummy.zip"
  )
  has_artifacts_bucket = (
    var.existing_artifacts_bucket_name != null &&
    var.existing_artifacts_bucket_name != ""
  )
}