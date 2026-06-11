resource "aws_db_subnet_group" "rds_subnet_group" {
  name = "hmrs-rds-subnet-group"

  subnet_ids = var.db_subnet_group_ids

  tags = {
    Name = "hmrs-rds-subnet-group"
  }
}


resource "random_password" "random_db_password" {
  length  = 32
  special = true
}

resource "aws_secretsmanager_secret" "hmrs_db_secret" {
  name = "hmrs-rds-credentials"
}

resource "aws_secretsmanager_secret_version" "hmrs_db_secret_value" {
  secret_id = aws_secretsmanager_secret.hmrs_db_secret.id

  secret_string = jsonencode({
    username = "dbadmin"
    password = random_password.random_db_password.result
  })
}

resource "aws_security_group" "hmrs_rds_sg" {
  name   = "hmrs-rds-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.ecs_security_group_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "postgres" {
  identifier = "hmrs-postgres"

  engine         = "postgres"
  engine_version = "16"

  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = "appdb"
  username = "dbadmin"

  manage_master_user_password = true

  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name

  vpc_security_group_ids = [
    aws_security_group.hmrs_rds_sg.id
  ]

  publicly_accessible = false

  skip_final_snapshot = true
}