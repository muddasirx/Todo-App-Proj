resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

resource "aws_db_instance" "main" {
  identifier     = "${var.project_name}-db"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = var.db_instance_class

  allocated_storage     = var.db_allocated_storage
  storage_encrypted     = true
  db_name                = var.db_name
  username               = var.db_username

  # Lets RDS generate and own the master password as a Secrets Manager
  # secret automatically — this is what satisfies "secrets in Secrets
  # Manager" for the DB credential, no manual secret needed.
  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false
  multi_az                = false

  backup_retention_period = 7
  # Dev/demo convenience. Set to false and configure final_snapshot_identifier
  # before this ever holds real data.
  skip_final_snapshot = true

  tags = {
    Name = "${var.project_name}-db"
  }
}
