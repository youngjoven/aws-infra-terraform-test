# VPC 모듈

EKS 클러스터를 위한 VPC 및 네트워킹 리소스를 생성하는 모듈입니다.

## 생성되는 리소스

- VPC
- Internet Gateway
- Public 서브넷 (여러 AZ에 분산)
- Private 서브넷 (여러 AZ에 분산)
- NAT Gateway (각 AZ마다)
- Elastic IP (NAT Gateway용)
- 라우팅 테이블 및 연결

## 사용 예시

```hcl
module "vpc" {
  source = "../../modules/vpc"

  vpc_name             = "eks-vpc"
  vpc_cidr             = "10.100.0.0/16"
  availability_zones   = ["ap-northeast-2a", "ap-northeast-2c"]
  public_subnet_cidrs  = ["10.100.1.0/24", "10.100.2.0/24"]
  private_subnet_cidrs = ["10.100.11.0/24", "10.100.12.0/24"]
  enable_nat_gateway   = true
  cluster_name         = "eks-cluster"

  tags = {
    Environment = "prod"
    Project     = "eks-project"
    Team        = "Team Domodachi"
  }
}
```

## 입력 변수

| 이름 | 설명 | 타입 | 기본값 | 필수 |
|------|------|------|--------|------|
| vpc_name | VPC 이름 | string | - | yes |
| vpc_cidr | VPC CIDR 블록 | string | - | yes |
| availability_zones | 가용 영역 목록 | list(string) | - | yes |
| public_subnet_cidrs | Public 서브넷 CIDR 목록 | list(string) | - | yes |
| private_subnet_cidrs | Private 서브넷 CIDR 목록 | list(string) | - | yes |
| enable_nat_gateway | NAT Gateway 활성화 여부 | bool | true | no |
| cluster_name | EKS 클러스터 이름 | string | - | yes |
| tags | 리소스 태그 | map(string) | {} | no |

## 출력 값

| 이름 | 설명 |
|------|------|
| vpc_id | VPC ID |
| vpc_cidr | VPC CIDR 블록 |
| public_subnet_ids | Public 서브넷 ID 목록 |
| private_subnet_ids | Private 서브넷 ID 목록 |
| nat_gateway_ids | NAT Gateway ID 목록 |
| internet_gateway_id | Internet Gateway ID |

## 주의사항

- EKS 클러스터를 위해 필수적인 태그가 자동으로 추가됩니다
- NAT Gateway는 AZ당 하나씩 생성되어 고가용성을 보장합니다
- Public 서브넷은 ELB용, Private 서브넷은 EKS 노드용으로 태그됩니다
