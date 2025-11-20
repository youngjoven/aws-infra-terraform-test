variable "vpc_name" {
  description = "VPC 이름"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string
}

variable "availability_zones" {
  description = "가용 영역 목록"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "Public 서브넷 CIDR 목록"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private 서브넷 CIDR 목록"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "NAT Gateway 활성화 여부"
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "EKS 클러스터 이름 (태깅용)"
  type        = string
}

variable "tags" {
  description = "리소스 태그"
  type        = map(string)
  default     = {}
}
