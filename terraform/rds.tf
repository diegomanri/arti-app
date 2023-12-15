resource "aws_db_instance" "artiapp_db" {
  identifier = "artiapp-db"

  engine            = "postgres"
  engine_version    = "13.4"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  # Database credentials and name
  username = "produser"
  password = aws_secretsmanager_secret_version.rds_password.secret_string
  port     = 5432

  # Networking and Security
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.artiapp_subnet_group.name

  # Backup
  backup_retention_period = 7
  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:00-06:00"

  # Additional settings
  skip_final_snapshot = true
  deletion_protection = false

  # Tags
  tags = {
    Environment = "production"
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "artiapp_subnet_group" {
  name       = "artiapp-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "artiapp-db-subnet-group"
  }
}

# I am getting Error: Unsupported attribute when using a rds module.
# So i'll be commenting out the rds module and using the rds resource instead.
# module "db" {
#   source  = "terraform-aws-modules/rds/aws"
#   version = "~> 4.0"

#   identifier = "artiapp-db"

#   engine            = "postgres"
#   engine_version    = "13.4"
#   instance_class    = "db.t3.micro"
#   allocated_storage = 20

#   # Database credentials and name
#   username = aws_ssm_parameter.rds_username.value
#   password = aws_secretsmanager_secret_version.rds_password.secret_string
#   db_name  = aws_ssm_parameter.rds_db_name.value
#   port     = "5432"

#   # Networking and Security
#   vpc_security_group_ids = [aws_security_group.rds_sg.id]
#   maintenance_window     = "Mon:00:00-Mon:03:00"
#   backup_window          = "03:00-06:00"

#   # Backup
#   backup_retention_period = 7

#   # Subnet group
#   create_db_subnet_group = true
#   subnet_ids             = module.vpc.private_subnets

#   # Tags
#   tags = {
#     Environment = "production"
#   }

#   # Deletion Protection
#   deletion_protection = false
# }
