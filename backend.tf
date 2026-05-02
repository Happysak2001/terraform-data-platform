terraform {
  # This tells Terraform: "store your memory in S3, not on my laptop"
  backend "s3" {
    bucket         = "data-platform-tfstate-2026"       # the S3 bucket we created in bootstrap
    key            = "global/terraform.tfstate"         # the file path inside the bucket
    region         = "us-east-1"
    use_lockfile   = true                               # native S3 locking (Terraform 1.10+)
    encrypt        = true                               # encrypt the state file
  }
}
