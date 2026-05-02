# These values get passed to other modules
# e.g. compute module needs vpc_id and public_subnet_id to place EC2 correctly

output "vpc_id" {
  description = "ID of the VPC — needed by security groups and RDS"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of public subnet — EC2 goes here"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "ID of private subnet — RDS goes here"
  value       = aws_subnet.private.id
}

output "private_subnet_2_id" {
  description = "ID of second private subnet — required by RDS subnet group"
  value       = aws_subnet.private_2.id
}
