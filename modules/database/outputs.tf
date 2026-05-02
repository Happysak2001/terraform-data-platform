output "rds_endpoint" {
  description = "Connection endpoint — use this to connect to MySQL from EC2"
  value       = aws_db_instance.mysql.endpoint
}

output "rds_db_name" {
  description = "The database name inside MySQL"
  value       = aws_db_instance.mysql.db_name
}
