variable "cluster_name" {
  description = "EKS 클러스터 이름"
  type        = string
}

variable "enable_ssm" {
  description = "SSM 접근을 위한 정책 활성화 여부 (디버깅용)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "리소스 태그"
  type        = map(string)
  default     = {}
}
