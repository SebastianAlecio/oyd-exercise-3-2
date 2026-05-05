output "invoke_url" {
  description = "Base invoke URL of the API Gateway HTTP API $default stage. Append /rates or /convert to call the Lambda."
  value       = aws_apigatewayv2_stage.default.invoke_url
}
