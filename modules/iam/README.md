# IAM 모듈

EKS 클러스터 및 노드 그룹을 위한 IAM 역할과 정책을 생성하는 모듈입니다.

## 생성되는 리소스

### EKS 클러스터용
- IAM 역할
- AmazonEKSClusterPolicy 정책 연결
- AmazonEKSVPCResourceController 정책 연결

### EKS 노드 그룹용
- IAM 역할
- AmazonEKSWorkerNodePolicy 정책 연결
- AmazonEKS_CNI_Policy 정책 연결
- AmazonEC2ContainerRegistryReadOnly 정책 연결
- AmazonSSMManagedInstanceCore 정책 연결 (선택적)

## 사용 예시

```hcl
module "iam" {
  source = "../../modules/iam"

  cluster_name = "eks-cluster"
  enable_ssm   = true

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
| enable_ssm | SSM 접근 정책 활성화 | bool | false | no |
| tags | 리소스 태그 | map(string) | {} | no |

## 출력 값

| 이름 | 설명 |
|------|------|
| cluster_role_arn | EKS 클러스터 역할 ARN |
| cluster_role_name | EKS 클러스터 역할 이름 |
| node_group_role_arn | EKS 노드 그룹 역할 ARN |
| node_group_role_name | EKS 노드 그룹 역할 이름 |

## 주의사항

- AWS 관리형 정책을 사용하여 AWS의 Best Practice를 따릅니다
- SSM 정책은 선택적이며, 노드에 직접 접근이 필요한 경우에만 활성화하세요
