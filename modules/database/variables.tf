variable "project_name" {
  description = "Prefix for all resource names"
  type        = string
}

variable "private_subnet_id" {
  description = "Private subnet ID from networking module"
  type        = string
}

variable "private_subnet_2_id" {
  description = "Second private subnet ID — RDS needs 2 AZs"
  type        = string
}

variable "rds_security_group_id" {
  description = "Security group ID from compute module — only EC2 can connect"
  type        = string
}

variable "db_username" {
  description = "Master username for MySQL"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Master password for MySQL — keep this secret"
  type        = string
  sensitive   = true    # Terraform will never print this in logs
}
