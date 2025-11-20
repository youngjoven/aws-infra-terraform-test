# ==================== VPC 출력 ====================
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public 서브넷 ID 목록"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private 서브넷 ID 목록"
  value       = module.vpc.private_subnet_ids
}

# ==================== IAM 출력 ====================
output "cluster_role_arn" {
  description = "EKS 클러스터 IAM 역할 ARN"
  value       = module.iam.cluster_role_arn
}

output "node_group_role_arn" {
  description = "EKS 노드 그룹 IAM 역할 ARN"
  value       = module.iam.node_group_role_arn
}

# ==================== EKS Cluster 출력 ====================
output "cluster_id" {
  description = "EKS 클러스터 ID"
  value       = module.eks_cluster.cluster_id
}

output "cluster_name" {
  description = "EKS 클러스터 이름"
  value       = module.eks_cluster.cluster_name
}

output "cluster_endpoint" {
  description = "EKS 클러스터 API 서버 엔드포인트"
  value       = module.eks_cluster.cluster_endpoint
}

output "cluster_version" {
  description = "EKS 클러스터 버전"
  value       = module.eks_cluster.cluster_version
}

output "cluster_security_group_id" {
  description = "EKS 클러스터 보안 그룹 ID"
  value       = module.eks_cluster.cluster_security_group_id
}

output "cluster_certificate_authority_data" {
  description = "EKS 클러스터 인증서 데이터 (base64 인코딩)"
  value       = module.eks_cluster.cluster_certificate_authority_data
  sensitive   = true
}

output "oidc_provider_arn" {
  description = "OIDC Provider ARN (IRSA용)"
  value       = module.eks_cluster.oidc_provider_arn
}

# ==================== EKS Node Group 출력 ====================
output "node_group_id" {
  description = "노드 그룹 ID"
  value       = module.eks_node_group.node_group_id
}

output "node_group_arn" {
  description = "노드 그룹 ARN"
  value       = module.eks_node_group.node_group_arn
}

output "node_group_status" {
  description = "노드 그룹 상태"
  value       = module.eks_node_group.node_group_status
}

# ==================== kubectl 설정 명령 ====================
output "kubectl_config_command" {
  description = "kubectl 설정 명령"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks_cluster.cluster_name}"
}
