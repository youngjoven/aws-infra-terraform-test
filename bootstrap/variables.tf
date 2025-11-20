variable "aws_region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-northeast-2"
}

variable "bucket_name" {
  description = "S3 버킷 이름 (계정 ID가 자동으로 추가됩니다)"
  type        = string
  default     = "eks-terraform-state"
}

variable "dynamodb_table_name" {
  description = "DynamoDB 테이블 이름"
  type        = string
  default     = "eks-terraform-state-lock"
}
