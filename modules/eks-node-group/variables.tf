variable "cluster_name" {
  description = "EKS 클러스터 이름"
  type        = string
}

variable "node_group_name" {
  description = "노드 그룹 이름"
  type        = string
}

variable "node_role_arn" {
  description = "노드 IAM 역할 ARN"
  type        = string
}

variable "subnet_ids" {
  description = "노드를 배치할 서브넷 ID 목록"
  type        = list(string)
}

variable "instance_types" {
  description = "인스턴스 타입 목록"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "capacity_type" {
  description = "용량 타입 (ON_DEMAND 또는 SPOT)"
  type        = string
  default     = "ON_DEMAND"
}

variable "desired_size" {
  description = "원하는 노드 수"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "최대 노드 수"
  type        = number
  default     = 4
}

variable "min_size" {
  description = "최소 노드 수"
  type        = number
  default     = 2
}

variable "disk_size" {
  description = "노드 EBS 볼륨 크기 (GB)"
  type        = number
  default     = 20
}

variable "enable_monitoring" {
  description = "상세 모니터링 활성화"
  type        = bool
  default     = false
}

variable "max_unavailable_percentage" {
  description = "업데이트 시 사용 불가능한 노드 최대 비율"
  type        = number
  default     = 33
}

variable "labels" {
  description = "노드 레이블"
  type        = map(string)
  default     = {}
}

variable "taints" {
  description = "노드 테인트"
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  default = []
}

variable "user_data_base64" {
  description = "사용자 데이터 (base64 인코딩)"
  type        = string
  default     = null
}

variable "tags" {
  description = "리소스 태그"
  type        = map(string)
  default     = {}
}
