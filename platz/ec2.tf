resource "aws_autoscaling_group" "this" {
  name_prefix         = var.name_prefix
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1
  vpc_zone_identifier = module.vpc.public_subnets
  #   health_check_type         = "ELB"
  #   health_check_grace_period = 300
  target_group_arns = [aws_lb_target_group.this.arn]

  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 0
    }
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "self" {
  key_name   = "self"
  public_key = file(pathexpand("~/.ssh/id_ed25519.pub"))
}

resource "aws_security_group" "instance" {
  name   = "${var.name_prefix}-instance"
  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group_rule" "instance_ssh_ingress" {
  security_group_id = aws_security_group.instance.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group_rule" "instance_egress" {
  security_group_id = aws_security_group.instance.id
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group_rule" "instance_lb_http_ingress" {
  security_group_id        = aws_security_group.instance.id
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.lb.id
}

resource "aws_launch_template" "this" {
  name_prefix   = var.name_prefix
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.self.key_name
  user_data     = data.cloudinit_config.this.rendered

  vpc_security_group_ids = [
    aws_security_group.instance.id,
    aws_security_group.db.id,
  ]

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 30
    }
  }

  #   instance_market_options {
  #     market_type = "spot"
  #   }
}
