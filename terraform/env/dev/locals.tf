locals {
  is_dummy_deploy = (
    var.lambda_zip_key == "lambda/dev-my-lambda-fn-dummy.zip" &&
    var.lambda_layer_zip_key == "lambda-layers/dev-my-lambda-layer-dummy.zip"
  )
}