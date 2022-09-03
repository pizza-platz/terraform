resource "aws_eks_node_group" "default" {
  cluster_name           = aws_eks_cluster.this.name
  node_group_name_prefix = "default"
  node_role_arn          = aws_iam_role.node.arn
  subnet_ids             = module.vpc.public_subnets

  scaling_config {
    min_size     = 1
    max_size     = 5
    desired_size = 1
  }

  instance_types = ["t3.xlarge"]
  capacity_type  = "SPOT"

  launch_template {
    id      = aws_launch_template.default.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      scaling_config[0].desired_size,
      launch_template[0].version,
    ]
  }
}

resource "aws_iam_role" "node" {
  name               = "eks-${var.cluster_name}-node"
  assume_role_policy = data.aws_iam_policy_document.node_assume_role.json
}

data "aws_iam_policy_document" "node_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node.name
}

resource "aws_launch_template" "default" {
  name = "eks-default-node-group"

  vpc_security_group_ids = [
    aws_eks_cluster.this.vpc_config[0].cluster_security_group_id,
    aws_security_group.nodes.id,
  ]
}

resource "aws_security_group" "nodes" {
  name   = "eks-${var.cluster_name}-nodes"
  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group_rule" "nodes_ingress" {
  security_group_id = aws_security_group.nodes.id
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  self              = true
}

resource "aws_security_group_rule" "nodes_egress" {
  security_group_id = aws_security_group.nodes.id
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  self              = true
}
