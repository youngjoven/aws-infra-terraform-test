output "cluster_security_group_id" {
  description = "클러스터 추가 보안 그룹 ID"
  value       = var.create_cluster_sg ? aws_security_group.eks_cluster_additional[0].id : null
}

output "node_security_group_id" {
  description = "노드 추가 보안 그룹 ID"
  value       = var.create_node_sg ? aws_security_group.eks_nodes_additional[0].id : null
}
