# ==================== 기본 설정 ====================
variable "aws_region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-northeast-2"
}

variable "default_tags" {
  description = "모든 리소스에 적용될 기본 태그"
  type        = map(string)
  default = {
    Environment = "prod"
    Project     = "eks-project"
    Team        = "Team Domodachi"
    ManagedBy   = "Terraform"
  }
}

# ==================== VPC 설정 ====================
variable "vpc_name" {
  description = "VPC 이름"
  type        = string
  default     = "eks-vpc"
}

variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string
  default     = "10.100.0.0/16"
}

variable "availability_zones" {
  description = "가용 영역 목록"
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2c"]
}

variable "public_subnet_cidrs" {
  description = "Public 서브넷 CIDR 목록"
  type        = list(string)
  default     = ["10.100.1.0/24", "10.100.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private 서브넷 CIDR 목록"
  type        = list(string)
  default     = ["10.100.11.0/24", "10.100.12.0/24"]
}

variable "enable_nat_gateway" {
  description = "NAT Gateway 활성화 여부"
  type        = bool
  default     = true
}

# ==================== IAM 설정 ====================
variable "enable_ssm" {
  description = "SSM 접근을 위한 정책 활성화 (디버깅용)"
  type        = bool
  default     = false
}

# ==================== Security Group 설정 ====================
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

# ==================== EKS Cluster 설정 ====================
variable "cluster_name" {
  description = "EKS 클러스터 이름"
  type        = string
  default     = "eks-cluster"
}

variable "cluster_version" {
  description = "EKS 클러스터 버전"
  type        = string
  default     = "1.31"
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

# ==================== EKS Node Group 설정 ====================
variable "node_group_name" {
  description = "노드 그룹 이름"
  type        = string
  default     = "default"
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
  default     = 2
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

variable "node_labels" {
  description = "노드 레이블"
  type        = map(string)
  default = {
    role = "worker"
  }
}

variable "node_taints" {
  description = "노드 테인트"
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  default = []
}
