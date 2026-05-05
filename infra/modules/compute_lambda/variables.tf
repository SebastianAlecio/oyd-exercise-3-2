variable "environment" {
  description = "Deployment environment name (e.g. dev, staging, prod). Used as a suffix on AWS resource names."
  type        = string
}

variable "name" {
  description = "Base name for the Lambda function and related resources. Combined with environment to form unique names."
  type        = string
}

variable "memory_size" {
  description = "Amount of memory in MB allocated to the Lambda function. CPU scales linearly with memory."
  type        = number
  default     = 128
}

variable "architectures" {
  description = "Lambda CPU architecture. Use [\"arm64\"] for Graviton2 (recommended, ~20% cheaper) or [\"x86_64\"]."
  type        = list(string)
  default     = ["arm64"]

  validation {
    condition     = length(var.architectures) == 1 && contains(["arm64", "x86_64"], var.architectures[0])
    error_message = "architectures must be either [\"arm64\"] or [\"x86_64\"]."
  }
}
