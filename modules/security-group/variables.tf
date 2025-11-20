variable "cluster_name" {
  description = "EKS 클러스터 이름"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "create_cluster_sg" {
  description = "클러스터 추가 보안 그룹 생성 여부"
  type        = bool
  default     = false
}

variable "create_node_sg" {
  description = "노드 추가 보안 그룹 생성 여부"
  type        = bool
  default     = false
}

variable "allow_https_from_cidrs" {
  description = "클러스터 API 서버 HTTPS 접근을 허용할 CIDR 목록"
  type        = list(string)
  default     = null
}

variable "allow_ssh_from_cidrs" {
  description = "노드 SSH 접근을 허용할 CIDR 목록"
  type        = list(string)
  default     = null
}

variable "tags" {
  description = "리소스 태그"
  type        = map(string)
  default     = {}
}
