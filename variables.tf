# ─────────────────────────────────────────
# VARIABLES — like function parameters for your whole project
# Change these values and everything updates automatically
# ─────────────────────────────────────────

variable "aws_region" {
  description = "Which AWS data center to use"
  type        = string
  default     = "us-east-1" # N. Virginia — cheapest and most common
}

variable "project_name" {
  description = "Prefix added to every resource name so you know what created it"
  type        = string
  default     = "data-platform"
}

variable "environment" {
  description = "dev, staging, or prod — controls naming and sizing"
  type        = string
  default     = "dev"
}

variable "key_pair_name" {
  description = "Name of the AWS key pair you create for SSH access to EC2"
  type        = string
}

variable "db_username" {
  description = "MySQL master username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "MySQL master password — keep this secret"
  type        = string
  sensitive   = true
}
