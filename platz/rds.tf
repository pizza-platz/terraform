resource "aws_db_instance" "this" {
  identifier_prefix       = "platz-db"
  allocated_storage       = 20
  engine                  = "postgres"
  engine_version          = "14.2"
  instance_class          = "db.t3.micro"
  db_subnet_group_name    = aws_db_subnet_group.this.name
  db_name                 = "platz"
  username                = "platz"
  password                = random_password.db.result
  backup_retention_period = 30
  vpc_security_group_ids  = [aws_security_group.db.id]
}

resource "random_password" "db" {
  length = 16
}

resource "aws_db_subnet_group" "this" {
  name_prefix = "platz"
  subnet_ids  = module.vpc.public_subnets

  tags = {
    Name = "Platz subnet group"
  }
}

resource "aws_security_group" "db" {
  name   = "platz-db"
  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group_rule" "db_ingress" {
  security_group_id = aws_security_group.db.id
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  self              = true
}

resource "aws_security_group_rule" "db_egress" {
  security_group_id = aws_security_group.db.id
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  self              = true
}
