# # Random password generator resource
# resource "random_password" "rds_pass" {
#   length  = 16
#   special = true
# }

# # AWS Secrets Manager
# #RDS Password
# resource "aws_secretsmanager_secret" "rds_password" {
#   name = "rds_password"
# }

# resource "aws_secretsmanager_secret_version" "rds_password" {
#   secret_id     = aws_secretsmanager_secret.rds_password.id
#   secret_string = random_password.rds_pass.result
# }

# # AWS Parameter Store
# resource "aws_ssm_parameter" "rds_username" {
#   name  = "/finarticles/rds_username"
#   type  = "String"
#   value = "produser"
# }

# resource "aws_ssm_parameter" "rds_host" {
#   name = "/finarticles/rds_host"
#   type = "String"
#   #value = module.db.db_instance_address
#   value = aws_db_instance.artiapp_db.address
# }

# resource "aws_ssm_parameter" "rds_db_name" {
#   name  = "/finarticles/rds_db_name"
#   type  = "String"
#   value = "artiappdb"
# }

# GHCR Token
resource "aws_secretsmanager_secret" "ghcr_token" {
  name = "ghcr_token"
}

resource "aws_secretsmanager_secret_version" "ghcr_token" {
  secret_id     = aws_secretsmanager_secret.ghcr_token.id
  secret_string = var.ghcr_token
}
