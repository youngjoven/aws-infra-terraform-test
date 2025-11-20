# EKS Cluster 모듈

EKS 클러스터 및 필수 Add-ons를 생성하는 모듈입니다.

## 생성되는 리소스

- EKS 클러스터
- EKS Add-ons:
  - VPC CNI (네트워킹)
  - CoreDNS (DNS)
  - kube-proxy (네트워크 프록시)
  - EBS CSI Driver (선택적)

## 사용 예시

```hcl
module "eks_cluster" {
  source = "../../modules/eks-cluster"

  cluster_name    = "eks-cluster"
  cluster_version = "1.31"
  cluster_role_arn = module.iam.cluster_role_arn

  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids

  endpoint_private_access = true
  endpoint_public_access  = true

  enabled_log_types = ["api", "audit"]
  enabled_addons    = ["vpc-cni", "coredns", "kube-proxy"]

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
| cluster_version | EKS 클러스터 버전 | string | "1.31" | no |
| cluster_role_arn | 클러스터 IAM 역할 ARN | string | - | yes |
| public_subnet_ids | Public 서브넷 ID 목록 | list(string) | - | yes |
| private_subnet_ids | Private 서브넷 ID 목록 | list(string) | - | yes |
| endpoint_private_access | Private 엔드포인트 활성화 | bool | true | no |
| endpoint_public_access | Public 엔드포인트 활성화 | bool | true | no |
| public_access_cidrs | Public 접근 허용 CIDR | list(string) | ["0.0.0.0/0"] | no |
| enabled_log_types | 활성화할 로그 타입 | list(string) | ["api", "audit"] | no |
| enabled_addons | 활성화할 Add-ons | list(string) | ["vpc-cni", "coredns", "kube-proxy"] | no |
| tags | 리소스 태그 | map(string) | {} | no |

## 출력 값

| 이름 | 설명 |
|------|------|
| cluster_id | EKS 클러스터 ID |
| cluster_name | EKS 클러스터 이름 |
| cluster_arn | EKS 클러스터 ARN |
| cluster_endpoint | API 서버 엔드포인트 |
| cluster_version | 클러스터 버전 |
| cluster_security_group_id | 클러스터 보안 그룹 ID |
| cluster_certificate_authority_data | 인증서 데이터 |
| oidc_provider_arn | OIDC Provider ARN |

## 로깅 옵션

다음 로그 타입을 활성화할 수 있습니다:
- `api`: API 서버 로그
- `audit`: 감사 로그
- `authenticator`: 인증 로그
- `controllerManager`: 컨트롤러 매니저 로그
- `scheduler`: 스케줄러 로그

## Add-ons

- **vpc-cni**: Pod 네트워킹 (필수)
- **coredns**: DNS 서비스 (필수)
- **kube-proxy**: 네트워크 프록시 (필수)
- **aws-ebs-csi-driver**: EBS 볼륨 지원 (선택적)

## 주의사항

- 클러스터 생성에는 약 10-15분이 소요됩니다
- Add-ons는 순차적으로 설치됩니다 (VPC CNI → CoreDNS → 나머지)
- 로깅을 활성화하면 CloudWatch Logs 비용이 발생합니다
