# ─────────────────────────────────────────
# SUBNET GROUP — tells RDS which rooms it can live in
# RDS requires at least 2 subnets in different AZs
# Think of it as: "database is allowed in these rooms only"
# ─────────────────────────────────────────

resource "aws_db_subnet_group" "main" {
  name        = "${var.project_name}-db-subnet-group"
  description = "Subnet group for RDS MySQL"
  subnet_ids  = [var.private_subnet_id, var.private_subnet_2_id]

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

# ─────────────────────────────────────────
# RDS MYSQL INSTANCE — the actual database
# Lives in the private subnet — no internet access
# Only the EC2 server can talk to it
# ─────────────────────────────────────────

resource "aws_db_instance" "mysql" {
  identifier        = "${var.project_name}-mysql"   # name shown in AWS console
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"                 # smallest size — free tier eligible
  allocated_storage = 20                            # 20 GB disk space

  db_name  = "dataplatform"                         # the default database created on startup
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.rds_security_group_id]  # the guard we built in Phase 3

  # These settings keep costs low for a learning project
  multi_az               = false   # no backup instance in second AZ (saves money)
  publicly_accessible    = false   # NEVER expose database to internet
  skip_final_snapshot    = true    # don't create a backup when we destroy it

  tags = {
    Name = "${var.project_name}-mysql"
  }
}
