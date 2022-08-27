locals {
  db_url = "postgres://${aws_db_instance.this.username}:${random_password.db.result}@${aws_db_instance.this.endpoint}/${aws_db_instance.this.db_name}"
}

resource "aws_db_instance" "this" {
  identifier_prefix       = "${var.name_prefix}-db"
  allocated_storage       = 20
  engine                  = "postgres"
  engine_version          = "14.3"
  instance_class          = "db.t3.micro"
  db_subnet_group_name    = aws_db_subnet_group.this.name
  db_name                 = "platz"
  username                = "platz"
  password                = random_password.db.result
  backup_retention_period = 14
  vpc_security_group_ids  = [data.terraform_remote_state.clusters.outputs.clusters[var.cluster_name].nodes_security_group_id]
  skip_final_snapshot     = true
}

resource "random_password" "db" {
  length           = 24
  override_special = "!#$%&*()-_=+[]{}<>?"
}

resource "aws_db_subnet_group" "this" {
  name_prefix = var.name_prefix
  subnet_ids  = data.terraform_remote_state.clusters.outputs.clusters[var.cluster_name].vpc_public_subnets

  tags = {
    Name = "Platz subnet group"
  }
}
