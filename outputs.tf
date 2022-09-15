output "bucket_id" {
  description = "The ID of the s3 bucket used for the state backup"
  value       = module.s3_bucket.s3_bucket_id
}
output "apigw_invoke_url" {
  description = "The API gateway invocation url"
  value       = module.api_gateway.default_apigatewayv2_stage_invoke_url
}
