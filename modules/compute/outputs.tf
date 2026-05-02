output "ec2_public_ip" {
  description = "Public IP of EC2 — use this to SSH in"
  value       = aws_instance.data_server.public_ip
}

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.data_server.id
}

output "ec2_security_group_id" {
  description = "EC2 security group ID — passed to RDS module"
  value       = aws_security_group.ec2.id
}

output "rds_security_group_id" {
  description = "RDS security group ID — passed to database module"
  value       = aws_security_group.rds.id
}
