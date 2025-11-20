# Security Group 모듈

EKS 클러스터 및 노드를 위한 추가 보안 그룹을 생성하는 모듈입니다.

## 개요

EKS는 자체적으로 보안 그룹을 생성하고 관리합니다. 이 모듈은 추가적인 제어가 필요한 경우에만 사용하세요.

## 생성되는 리소스 (선택적)

- 클러스터 추가 보안 그룹
- 노드 추가 보안 그룹
- 필요한 인바운드/아웃바운드 규칙

## 사용 예시

```hcl
module "security_group" {
  source = "../../modules/security-group"

  cluster_name    = "eks-cluster"
  vpc_id          = module.vpc.vpc_id
  create_node_sg  = true
  create_cluster_sg = false

  # SSH 접근은 선택적
  # allow_ssh_from_cidrs = ["10.100.0.0/16"]

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
| cluster_name | EKS 클러스터 이름 | string | - | yes |
| vpc_id | VPC ID | string | - | yes |
| create_cluster_sg | 클러스터 추가 보안 그룹 생성 | bool | false | no |
| create_node_sg | 노드 추가 보안 그룹 생성 | bool | false | no |
| allow_https_from_cidrs | HTTPS 접근 허용 CIDR | list(string) | null | no |
| allow_ssh_from_cidrs | SSH 접근 허용 CIDR | list(string) | null | no |
| tags | 리소스 태그 | map(string) | {} | no |

## 출력 값

| 이름 | 설명 |
|------|------|
| cluster_security_group_id | 클러스터 추가 보안 그룹 ID |
| node_security_group_id | 노드 추가 보안 그룹 ID |

## 주의사항

- 대부분의 경우 EKS가 자동으로 생성하는 보안 그룹으로 충분합니다
- 추가 보안 그룹은 특별한 요구사항이 있을 때만 사용하세요
- SSH 접근은 보안상 권장되지 않습니다 (SSM Session Manager 사용 권장)
