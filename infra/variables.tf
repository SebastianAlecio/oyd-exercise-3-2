variable "aws_region" {
  description = "AWS region in which all resources are provisioned."
  type        = string
}

variable "environment" {
  description = "Deployment environment name (e.g. dev, staging, prod)."
  type        = string
}

variable "name" {
  description = "Base name for the Lambda function and related resources."
  type        = string
}

variable "memory_size" {
  description = "Memory in MB allocated to the Lambda function."
  type        = number
  default     = 128
}

variable "architectures" {
  description = "Lambda CPU architecture: [\"arm64\"] or [\"x86_64\"]."
  type        = list(string)
  default     = ["arm64"]
}
