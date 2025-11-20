output "node_group_id" {
  description = "노드 그룹 ID"
  value       = aws_eks_node_group.main.id
}

output "node_group_arn" {
  description = "노드 그룹 ARN"
  value       = aws_eks_node_group.main.arn
}

output "node_group_status" {
  description = "노드 그룹 상태"
  value       = aws_eks_node_group.main.status
}

output "node_group_resources" {
  description = "노드 그룹 리소스 정보"
  value       = aws_eks_node_group.main.resources
}

output "launch_template_id" {
  description = "Launch Template ID"
  value       = aws_launch_template.node_group.id
}

output "launch_template_latest_version" {
  description = "Launch Template 최신 버전"
  value       = aws_launch_template.node_group.latest_version
}
