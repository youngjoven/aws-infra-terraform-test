# Production 환경 EKS 클러스터 구성
# 모든 모듈을 조합하여 완전한 EKS 인프라 생성

# VPC 모듈
module "vpc" {
  source = "../../modules/vpc"

  vpc_name             = var.vpc_name
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_nat_gateway   = var.enable_nat_gateway
  cluster_name         = var.cluster_name

  tags = var.default_tags
}

# IAM 모듈
module "iam" {
  source = "../../modules/iam"

  cluster_name = var.cluster_name
  enable_ssm   = var.enable_ssm

  tags = var.default_tags
}

# Security Group 모듈 (선택적)
module "security_group" {
  source = "../../modules/security-group"

  cluster_name      = var.cluster_name
  vpc_id            = module.vpc.vpc_id
  create_cluster_sg = var.create_cluster_sg
  create_node_sg    = var.create_node_sg

  tags = var.default_tags
}

# EKS Cluster 모듈
module "eks_cluster" {
  source = "../../modules/eks-cluster"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  cluster_role_arn = module.iam.cluster_role_arn

  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids

  endpoint_private_access = var.endpoint_private_access
  endpoint_public_access  = var.endpoint_public_access
  public_access_cidrs     = var.public_access_cidrs

  enabled_log_types = var.enabled_log_types
  enabled_addons    = var.enabled_addons

  tags = var.default_tags

  depends_on = [
    module.iam
  ]
}

# EKS Node Group 모듈
module "eks_node_group" {
  source = "../../modules/eks-node-group"

  cluster_name    = module.eks_cluster.cluster_name
  node_group_name = var.node_group_name
  node_role_arn   = module.iam.node_group_role_arn
  subnet_ids      = module.vpc.private_subnet_ids

  instance_types = var.instance_types
  capacity_type  = var.capacity_type

  desired_size = var.desired_size
  max_size     = var.max_size
  min_size     = var.min_size

  disk_size         = var.disk_size
  enable_monitoring = var.enable_monitoring

  labels = var.node_labels
  taints = var.node_taints

  tags = var.default_tags

  depends_on = [
    module.eks_cluster,
    module.iam
  ]
}
