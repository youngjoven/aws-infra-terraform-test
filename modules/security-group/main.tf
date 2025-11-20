# Security Group 모듈
# EKS 클러스터 및 노드를 위한 추가 보안 그룹 생성
# 참고: EKS는 자체적으로 보안 그룹을 생성하지만, 추가 제어가 필요한 경우 사용

# EKS 클러스터 추가 보안 그룹
resource "aws_security_group" "eks_cluster_additional" {
  count = var.create_cluster_sg ? 1 : 0

  name_prefix = "${var.cluster_name}-cluster-additional-"
  description = "Additional security group for EKS cluster"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-cluster-additional-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# 클러스터 보안 그룹 - HTTPS 인바운드 (선택적)
resource "aws_security_group_rule" "cluster_https_ingress" {
  count = var.create_cluster_sg && var.allow_https_from_cidrs != null ? 1 : 0

  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.allow_https_from_cidrs
  description       = "Allow HTTPS from specified CIDRs"
  security_group_id = aws_security_group.eks_cluster_additional[0].id
}

# EKS 노드 추가 보안 그룹
resource "aws_security_group" "eks_nodes_additional" {
  count = var.create_node_sg ? 1 : 0

  name_prefix = "${var.cluster_name}-nodes-additional-"
  description = "Additional security group for EKS nodes"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name                                        = "${var.cluster_name}-nodes-additional-sg"
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# 노드 보안 그룹 - 모든 아웃바운드 허용
resource "aws_security_group_rule" "nodes_egress_all" {
  count = var.create_node_sg ? 1 : 0

  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic"
  security_group_id = aws_security_group.eks_nodes_additional[0].id
}

# 노드 간 통신 허용
resource "aws_security_group_rule" "nodes_ingress_self" {
  count = var.create_node_sg ? 1 : 0

  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  self              = true
  description       = "Allow nodes to communicate with each other"
  security_group_id = aws_security_group.eks_nodes_additional[0].id
}

# SSH 접근 허용 (선택적)
resource "aws_security_group_rule" "nodes_ssh_ingress" {
  count = var.create_node_sg && var.allow_ssh_from_cidrs != null ? 1 : 0

  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.allow_ssh_from_cidrs
  description       = "Allow SSH from specified CIDRs"
  security_group_id = aws_security_group.eks_nodes_additional[0].id
}
