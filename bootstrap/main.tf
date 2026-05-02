terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Tell Terraform: "talk to AWS, in this region"
provider "aws" {
  region = "us-east-1"
}

# ─────────────────────────────────────────
# S3 BUCKET — stores the terraform.tfstate file
# (like Google Drive for Terraform's memory)
# ─────────────────────────────────────────

resource "aws_s3_bucket" "terraform_state" {
  bucket = "data-platform-tfstate-2026"

}

# Keep a history of every state file change
# (like version history in Google Docs — you can roll back)
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Encrypt the state file at rest
# (state files contain sensitive info like DB passwords)
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block ALL public access — nobody on the internet should see this
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ─────────────────────────────────────────
# DYNAMODB TABLE — the "Do Not Disturb" sign
# prevents two people running terraform apply at same time
# ─────────────────────────────────────────

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "data-platform-terraform-locks"
  billing_mode = "PAY_PER_REQUEST" # only pay when the lock is used
  hash_key     = "LockID"          # every lock entry has a unique ID

  attribute {
    name = "LockID"
    type = "S" # S = String
  }
}

# ─────────────────────────────────────────
# OUTPUTS — print these values after terraform apply
# you'll need them in the next step
# ─────────────────────────────────────────

output "s3_bucket_name" {
  description = "Copy this into backend.tf"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "dynamodb_table_name" {
  description = "Copy this into backend.tf"
  value       = aws_dynamodb_table.terraform_locks.name
}
