variable "cluster_name" {
  description = "EKS 클러스터 이름"
  type        = string
}

variable "cluster_version" {
  description = "EKS 클러스터 버전"
  type        = string
  default     = "1.31"
}

variable "cluster_role_arn" {
  description = "EKS 클러스터 IAM 역할 ARN"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public 서브넷 ID 목록"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private 서브넷 ID 목록"
  type        = list(string)
}

variable "endpoint_private_access" {
  description = "Private API 서버 엔드포인트 활성화"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Public API 서버 엔드포인트 활성화"
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "Public 엔드포인트 접근 허용 CIDR 목록"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_security_group_ids" {
  description = "클러스터 추가 보안 그룹 ID 목록"
  type        = list(string)
  default     = []
}

variable "enabled_log_types" {
  description = "활성화할 로그 타입 목록"
  type        = list(string)
  default     = ["api", "audit"]
}

variable "enabled_addons" {
  description = "활성화할 EKS Add-ons 목록"
  type        = list(string)
  default     = ["vpc-cni", "coredns", "kube-proxy"]
}

variable "vpc_cni_version" {
  description = "VPC CNI Add-on 버전 (null이면 최신 버전)"
  type        = string
  default     = null
}

variable "coredns_version" {
  description = "CoreDNS Add-on 버전 (null이면 최신 버전)"
  type        = string
  default     = null
}

variable "kube_proxy_version" {
  description = "kube-proxy Add-on 버전 (null이면 최신 버전)"
  type        = string
  default     = null
}

variable "ebs_csi_driver_version" {
  description = "EBS CSI Driver Add-on 버전 (null이면 최신 버전)"
  type        = string
  default     = null
}

variable "tags" {
  description = "리소스 태그"
  type        = map(string)
  default     = {}
}
