output "cluster_id" {
  description = "EKS 클러스터 ID"
  value       = aws_eks_cluster.main.id
}

output "cluster_name" {
  description = "EKS 클러스터 이름"
  value       = aws_eks_cluster.main.name
}

output "cluster_arn" {
  description = "EKS 클러스터 ARN"
  value       = aws_eks_cluster.main.arn
}

output "cluster_endpoint" {
  description = "EKS 클러스터 엔드포인트"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_version" {
  description = "EKS 클러스터 버전"
  value       = aws_eks_cluster.main.version
}

output "cluster_platform_version" {
  description = "EKS 클러스터 플랫폼 버전"
  value       = aws_eks_cluster.main.platform_version
}

output "cluster_security_group_id" {
  description = "EKS 클러스터 보안 그룹 ID"
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "cluster_certificate_authority_data" {
  description = "EKS 클러스터 인증서 데이터"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

output "oidc_provider_arn" {
  description = "OIDC Provider ARN (IRSA용)"
  value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
}
