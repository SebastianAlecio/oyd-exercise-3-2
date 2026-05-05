output "invoke_url" {
  description = "Base invoke URL of the API Gateway HTTP API $default stage."
  value       = module.compute_lambda.invoke_url
}
