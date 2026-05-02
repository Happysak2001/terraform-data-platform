output "raw_data_bucket_name" {
  description = "Drop raw data files here to trigger the pipeline"
  value       = aws_s3_bucket.raw_data.bucket
}

output "lambda_function_name" {
  description = "Name of the ingestion Lambda function"
  value       = aws_lambda_function.ingestion.function_name
}

output "cloudwatch_log_group" {
  description = "Check this in AWS Console to see Lambda logs"
  value       = aws_cloudwatch_log_group.lambda_logs.name
}
