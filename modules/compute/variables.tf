variable "project_name" {
  description = "Prefix for all resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID from networking module"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID — EC2 goes here"
  type        = string
}

variable "instance_type" {
  description = "EC2 size — t3.micro is free tier eligible"
  type        = string
  default     = "t3.micro"
}

variable "key_pair_name" {
  description = "Name of the AWS key pair for SSH access"
  type        = string
}

variable "iam_instance_profile" {
  description = "IAM instance profile name — gives EC2 permission to access S3"
  type        = string
}
