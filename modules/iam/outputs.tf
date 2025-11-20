output "cluster_role_arn" {
  description = "EKS 클러스터 역할 ARN"
  value       = aws_iam_role.eks_cluster.arn
}

output "cluster_role_name" {
  description = "EKS 클러스터 역할 이름"
  value       = aws_iam_role.eks_cluster.name
}

output "node_group_role_arn" {
  description = "EKS 노드 그룹 역할 ARN"
  value       = aws_iam_role.eks_node_group.arn
}

output "node_group_role_name" {
  description = "EKS 노드 그룹 역할 이름"
  value       = aws_iam_role.eks_node_group.name
}
