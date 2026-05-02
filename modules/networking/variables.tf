variable "project_name" {
  description = "Prefix for all resource names"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "IP range for the entire VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "IP range for public subnet (EC2 lives here)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "IP range for private subnet (RDS lives here)"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_2_cidr" {
  description = "Second private subnet — RDS requires 2 AZs"
  type        = string
  default     = "10.0.3.0/24"
}
