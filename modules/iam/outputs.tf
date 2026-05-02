output "ec2_instance_profile_name" {
  description = "Attach this to EC2 so it can access S3"
  value       = aws_iam_instance_profile.ec2_profile.name
}

output "lambda_role_arn" {
  description = "Lambda uses this ARN to assume its role"
  value       = aws_iam_role.lambda_role.arn
}
