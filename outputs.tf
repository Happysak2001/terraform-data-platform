# ─────────────────────────────────────────
# OUTPUTS — printed after every terraform apply
# ─────────────────────────────────────────

output "ec2_public_ip" {
  description = "SSH into your server using this IP"
  value       = module.compute.ec2_public_ip
}

output "rds_endpoint" {
  description = "Connect to MySQL using this endpoint from EC2"
  value       = module.database.rds_endpoint
}

output "raw_data_bucket" {
  description = "Drop raw data files here to trigger the pipeline"
  value       = module.data_layer.raw_data_bucket_name
}

output "lambda_function" {
  description = "Lambda function that processes incoming files"
  value       = module.data_layer.lambda_function_name
}

output "cloudwatch_logs" {
  description = "Check Lambda logs here in AWS Console"
  value       = module.data_layer.cloudwatch_log_group
}
