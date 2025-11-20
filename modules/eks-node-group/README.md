# EKS Node Group 모듈

EKS Managed Node Group을 생성하는 모듈입니다.

## 생성되는 리소스

- Launch Template (노드 설정)
- EKS Managed Node Group
- Auto Scaling 설정

## 사용 예시

```hcl
module "eks_node_group" {
  source = "../../modules/eks-node-group"

  cluster_name    = "eks-cluster"
  node_group_name = "default"
  node_role_arn   = module.iam.node_group_role_arn
  subnet_ids      = module.vpc.private_subnet_ids

  instance_types = ["t3.medium"]
  capacity_type  = "ON_DEMAND"

  desired_size = 2
  max_size     = 2
  min_size     = 2

  disk_size = 20

  labels = {
    role = "worker"
  }

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
| node_group_name | 노드 그룹 이름 | string | - | yes |
| node_role_arn | 노드 IAM 역할 ARN | string | - | yes |
| subnet_ids | 서브넷 ID 목록 | list(string) | - | yes |
| instance_types | 인스턴스 타입 목록 | list(string) | ["t3.medium"] | no |
| capacity_type | 용량 타입 | string | "ON_DEMAND" | no |
| desired_size | 원하는 노드 수 | number | 2 | no |
| max_size | 최대 노드 수 | number | 4 | no |
| min_size | 최소 노드 수 | number | 2 | no |
| disk_size | EBS 볼륨 크기 (GB) | number | 20 | no |
| enable_monitoring | 상세 모니터링 활성화 | bool | false | no |
| labels | 노드 레이블 | map(string) | {} | no |
| taints | 노드 테인트 | list(object) | [] | no |
| tags | 리소스 태그 | map(string) | {} | no |

## 출력 값

| 이름 | 설명 |
|------|------|
| node_group_id | 노드 그룹 ID |
| node_group_arn | 노드 그룹 ARN |
| node_group_status | 노드 그룹 상태 |
| node_group_resources | 노드 그룹 리소스 정보 |
| launch_template_id | Launch Template ID |
| launch_template_latest_version | Launch Template 최신 버전 |

## 특징

- **Launch Template**: 노드 설정을 세밀하게 제어
- **Auto Scaling**: 자동 확장/축소 지원
- **IMDSv2**: 메타데이터 보안 강화
- **암호화**: EBS 볼륨 자동 암호화
- **GP3**: 최신 EBS 볼륨 타입 사용

## 주의사항

- Private 서브넷에 노드를 배치하는 것을 권장합니다
- `desired_size`는 Auto Scaling에 의해 변경될 수 있으므로 ignore_changes 처리됨
- Spot 인스턴스를 사용하려면 `capacity_type = "SPOT"` 설정
- 노드 그룹 업데이트 시 최대 33%의 노드가 일시적으로 사용 불가능할 수 있음
