# EKS Cluster 모듈
# EKS 클러스터 및 Add-ons 생성

# EKS 클러스터
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = var.cluster_role_arn

  vpc_config {
    subnet_ids              = concat(var.public_subnet_ids, var.private_subnet_ids)
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
    security_group_ids      = var.cluster_security_group_ids
  }

  enabled_cluster_log_types = var.enabled_log_types

  tags = merge(
    var.tags,
    {
      Name = var.cluster_name
    }
  )

  depends_on = [
    var.cluster_role_arn
  ]
}

# EKS Add-on: VPC CNI
resource "aws_eks_addon" "vpc_cni" {
  count = contains(var.enabled_addons, "vpc-cni") ? 1 : 0

  cluster_name             = aws_eks_cluster.main.name
  addon_name               = "vpc-cni"
  addon_version            = var.vpc_cni_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  tags = var.tags
}

# EKS Add-on: CoreDNS
resource "aws_eks_addon" "coredns" {
  count = contains(var.enabled_addons, "coredns") ? 1 : 0

  cluster_name             = aws_eks_cluster.main.name
  addon_name               = "coredns"
  addon_version            = var.coredns_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  tags = var.tags

  depends_on = [
    aws_eks_addon.vpc_cni
  ]
}

# EKS Add-on: kube-proxy
resource "aws_eks_addon" "kube_proxy" {
  count = contains(var.enabled_addons, "kube-proxy") ? 1 : 0

  cluster_name             = aws_eks_cluster.main.name
  addon_name               = "kube-proxy"
  addon_version            = var.kube_proxy_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  tags = var.tags
}

# EKS Add-on: EBS CSI Driver (선택적)
resource "aws_eks_addon" "ebs_csi_driver" {
  count = contains(var.enabled_addons, "aws-ebs-csi-driver") ? 1 : 0

  cluster_name             = aws_eks_cluster.main.name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = var.ebs_csi_driver_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  tags = var.tags
}
