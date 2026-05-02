variable "project_name" {
  description = "Prefix for all resource names"
  type        = string
}

variable "lambda_role_arn" {
  description = "IAM role ARN for Lambda — from Phase 5"
  type        = string
}
