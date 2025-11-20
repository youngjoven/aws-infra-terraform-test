# AWS EKS Terraform 구현 계획

## 📋 프로젝트 개요

Terraform을 사용하여 AWS EKS(Elastic Kubernetes Service) 클러스터를 모듈화된 구조로 구현합니다.

---

## 🎯 구현 목표

1. **모듈화된 Terraform 구조** 구축
2. **재사용 가능한 EKS 인프라** 구성
3. **Best Practice** 적용 (보안, 고가용성, 확장성)
4. **Production-ready** 환경 구성

---

## 📁 디렉토리 구조

```
terraform_test/
├── modules/                      # 재사용 가능한 모듈
│   ├── vpc/                     # VPC 모듈
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   ├── security-group/          # Security Group 모듈
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   ├── iam/                     # IAM 역할/정책 모듈
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   ├── eks-cluster/             # EKS 클러스터 모듈
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   └── eks-node-group/          # EKS 노드 그룹 모듈
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── README.md
├── environments/                 # 환경별 설정
│   └── dev/                     # 개발 환경
│       ├── main.tf              # 메인 구성
│       ├── variables.tf         # 변수 정의
│       ├── terraform.tfvars     # 변수 값
│       ├── outputs.tf           # 출력 값
│       ├── providers.tf         # Provider 설정
│       └── backend.tf           # Backend 설정 (선택적)
├── plan.md                      # 이 파일
└── README.md                    # 프로젝트 설명
```

---

## 🏗️ 아키텍처 구성 요소

### 1. **VPC 모듈**
- VPC 생성
- Public 서브넷 (NAT Gateway, Load Balancer용)
- Private 서브넷 (EKS 노드용)
- Internet Gateway
- NAT Gateway
- Route Tables
- VPC Endpoints (선택적)

### 2. **Security Group 모듈**
- EKS 클러스터 보안 그룹
- 노드 보안 그룹
- 필요한 인바운드/아웃바운드 규칙

### 3. **IAM 모듈**
- EKS 클러스터 역할
- 노드 그룹 역할
- 필요한 정책 연결
- IRSA (IAM Roles for Service Accounts) 설정 (선택적)

### 4. **EKS Cluster 모듈**
- EKS 클러스터 생성
- 클러스터 엔드포인트 설정
- 로깅 설정
- Add-ons 설치

### 5. **EKS Node Group 모듈**
- Managed Node Group 생성
- Auto Scaling 설정
- Launch Template 구성
- Taints & Labels (선택적)

---

## 📝 모듈화 가이드

### 모듈이란?

Terraform 모듈은 **재사용 가능한 인프라 코드의 컨테이너**입니다.
- 복잡한 인프라를 작은 단위로 분리
- 코드 재사용성 향상
- 유지보수 용이
- 표준화된 인프라 구성

### 모듈 구조

각 모듈은 다음 파일로 구성됩니다:

1. **main.tf**: 주요 리소스 정의
2. **variables.tf**: 입력 변수 정의
3. **outputs.tf**: 출력 값 정의
4. **README.md**: 모듈 사용 가이드

### 모듈 사용 방법

```hcl
# 모듈 호출 예시
module "vpc" {
  source = "../../modules/vpc"

  vpc_name             = "eks-vpc"
  vpc_cidr             = "10.0.0.0/16"
  availability_zones   = ["ap-northeast-2a", "ap-northeast-2c"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]

  tags = {
    Environment = "dev"
    Project     = "eks-cluster"
  }
}

# 모듈의 출력 값 사용
resource "aws_instance" "example" {
  subnet_id = module.vpc.private_subnet_ids[0]
}
```

### 모듈화 Best Practices

1. **단일 책임 원칙**: 각 모듈은 하나의 명확한 목적을 가져야 함
2. **느슨한 결합**: 모듈 간 의존성 최소화
3. **명확한 인터페이스**: 변수와 출력을 통한 명확한 입출력
4. **문서화**: README.md로 사용법 설명
5. **버전 관리**: 모듈 버전 관리 (Git 태그 사용)

---

## ❓ 구성 질문 사항

다음 질문에 답변해주시면 구체적인 구현을 시작하겠습니다.

### 1. EKS 버전
**[Question]**: 어떤 EKS 버전을 사용하시겠습니까?
- 최신 버전: 1.31
- 안정 버전: 1.30
- 기타 버전: (명시해주세요)

**[Answer]**: 1.31 버전을 사용


### 2. 리전 설정
**[Question]**: AWS 리전은 어디로 설정하시겠습니까?
- 현재 설정: ap-northeast-2 (서울)
- 변경 희망: (명시해주세요)

**[Answer]**: ap-northeast-2 서울


### 3. VPC 네트워크 설정
**[Question]**: VPC CIDR 블록과 서브넷 구성은 어떻게 하시겠습니까?
- 추천: 10.0.0.0/16 (65,536개 IP)
  - Public 서브넷: 10.0.1.0/24, 10.0.2.0/24 (각 256개 IP)
  - Private 서브넷: 10.0.11.0/24, 10.0.12.0/24 (각 256개 IP)
- 사용자 정의: (명시해주세요)

**[Answer]**: 10.100.0.0/16으로 진행. Public 서브넷: 10.100.1.0/24, 10.100.2.0/24, Private 서브넷: 10.100.11.0/24, 10.100.12.0/24로 진행 부탁한다.


### 4. 가용 영역 (AZ)
**[Question]**: 몇 개의 가용 영역을 사용하시겠습니까?
- 추천: 2개 (고가용성과 비용 균형)
  - ap-northeast-2a, ap-northeast-2c
- 3개 (더 높은 가용성)
  - ap-northeast-2a, ap-northeast-2b, ap-northeast-2c
- 1개 (테스트용, 비용 절감)

**[Answer]**: 가용 영역은 2개로 진행하자. 


### 5. NAT Gateway 설정
**[Question]**: NAT Gateway를 몇 개 생성하시겠습니까?
- 1개: 비용 절감 (단일 장애점 존재)
- AZ당 1개: 고가용성 (추천)
- 0개: VPC Endpoints만 사용 (비용 최소화, 제한적)

**[Answer]**: NAT Gateway는 AZ당 1개로 진행하자. 


### 6. 노드 그룹 타입
**[Question]**: 어떤 타입의 노드 그룹을 사용하시겠습니까?
- Managed Node Group (추천): AWS가 관리, 쉬운 업그레이드
- Self-Managed Node Group: 더 많은 제어, 복잡함
- Fargate: 서버리스, 높은 비용

**[Answer]**: Managed Node Group으로 진행하자


### 7. 인스턴스 타입
**[Question]**: 노드의 인스턴스 타입은 무엇으로 하시겠습니까?
- t3.medium (2 vCPU, 4GB RAM) - 개발/테스트용
- t3.large (2 vCPU, 8GB RAM) - 소규모 프로덕션
- m5.large (2 vCPU, 8GB RAM) - 일반적인 워크로드
- m5.xlarge (4 vCPU, 16GB RAM) - 더 높은 성능
- 기타: (명시해주세요)

**[Answer]**: t3.medium의 개발/테스트용으로 진행하자


### 8. 노드 수
**[Question]**: 노드 그룹의 크기를 어떻게 설정하시겠습니까?
- 최소 노드 수: (예: 2)
- 원하는 노드 수: (예: 2)
- 최대 노드 수: (예: 4)

**[Answer]**:
- 최소: 2
- 원하는: 2
- 최대: 2


### 9. 디스크 크기
**[Question]**: 각 노드의 EBS 볼륨 크기는 얼마로 하시겠습니까?
- 20GB (기본, 최소)
- 50GB (추천)
- 100GB (대용량 워크로드)
- 기타: (명시해주세요)

**[Answer]**: 20GB 기본, 최소로 진행하자


### 10. EKS Add-ons
**[Question]**: 어떤 EKS Add-ons를 설치하시겠습니까?
- [v] VPC CNI (필수, 네트워킹)
- [v] CoreDNS (필수, DNS)
- [v] kube-proxy (필수, 네트워크 프록시)
- [ ] AWS EBS CSI Driver (EBS 볼륨 사용 시)
- [ ] AWS Load Balancer Controller (ALB/NLB 사용 시)

**[Answer]**: (체크해주세요)


### 11. 로깅 설정
**[Question]**: EKS 컨트롤 플레인 로깅을 활성화하시겠습니까?
- [v] api (API 서버 로그)
- [v] audit (감사 로그)
- [ ] authenticator (인증 로그)
- [ ] controllerManager (컨트롤러 매니저 로그)
- [ ] scheduler (스케줄러 로그)
- [ ] 모두 비활성화 (비용 절감)

**[Answer]**: (체크해주세요)


### 12. 퍼블릭 액세스
**[Question]**: EKS API 서버 엔드포인트 액세스를 어떻게 설정하시겠습니까?
- Public & Private (추천): 인터넷과 VPC 내부에서 모두 접근 가능
- Private only: VPC 내부에서만 접근 (Bastion 필요)
- Public only: 인터넷에서만 접근 (비추천)

**[Answer]**: Public & Private 모두 접근 가능으로 진행


### 13. Bastion 호스트
**[Question]**: Bastion 호스트를 생성하시겠습니까?
- Yes: Private 서브넷 접근 및 디버깅용
- No: 비용 절감

**[Answer]**: 생성 하지 마세요.


### 14. 태그 전략
**[Question]**: 리소스 태그를 어떻게 설정하시겠습니까?
- Environment: (예: dev, staging, prod)
- Project: (예: eks-cluster)
- Team: (예: devops)
- 기타 태그: (명시해주세요)

**[Answer]**:
```
Environment = prod
Project = eks-project
Team = Team Domodachi
```


### 15. Terraform Backend
**[Question]**: Terraform State를 어디에 저장하시겠습니까?
- Local: 로컬 파일 시스템 (간단, 협업 불가)
- S3 + DynamoDB: 원격 저장 및 State Lock (추천, 협업 가능)
- Terraform Cloud: Terraform Cloud 사용

**[Answer]**: S3 + DynamoDB로 한다. 좋은 생각인데? 이거 어떻게 하는 건지 좀 알려줄래?


---

## 🚀 구현 단계

답변을 받은 후 다음 순서로 구현하겠습니다:

### Phase 1: 기본 설정
1. 프로젝트 디렉토리 구조 생성
2. Provider 설정
3. Backend 설정 (선택 시)

### Phase 2: VPC 모듈
1. VPC 모듈 생성
2. 서브넷, 라우팅 테이블, NAT Gateway 구성
3. VPC 태깅 (EKS 요구사항)

### Phase 3: IAM 모듈
1. EKS 클러스터 역할 생성
2. 노드 그룹 역할 생성
3. 필요한 정책 연결

### Phase 4: Security Group 모듈
1. 클러스터 보안 그룹 생성
2. 노드 보안 그룹 생성
3. 필요한 규칙 추가

### Phase 5: EKS Cluster 모듈
1. EKS 클러스터 생성
2. Add-ons 설치
3. 로깅 설정

### Phase 6: EKS Node Group 모듈
1. Managed Node Group 생성
2. Auto Scaling 설정
3. Launch Template 구성

### Phase 7: 통합 및 테스트
1. 환경별 설정 (dev) 작성
2. Terraform 실행
   - `terraform init`
   - `terraform plan`
   - `terraform apply`
3. kubectl 설정 및 클러스터 접근 테스트

### Phase 8: 문서화
1. README.md 작성
2. 각 모듈 문서화
3. 사용 예시 추가

---

## 📚 참고 자료

- [AWS EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [Terraform AWS Provider - EKS](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster)
- [Terraform Module Guidelines](https://www.terraform.io/docs/language/modules/develop/index.html)

---

## ⚠️ 주의사항

1. **비용**: EKS 클러스터는 시간당 $0.10, NAT Gateway는 시간당 $0.045 + 데이터 전송 비용이 발생합니다
2. **보안**: 민감한 정보(credentials)는 절대 Git에 커밋하지 마세요
3. **State 관리**: terraform.tfstate 파일은 민감한 정보를 포함하므로 안전하게 관리해야 합니다
4. **리소스 삭제**: 사용하지 않을 때는 `terraform destroy`로 모든 리소스를 삭제하세요

---

## ✅ 다음 단계

위의 질문에 답변해주시면:
1. 맞춤형 Terraform 코드 생성
2. 모듈별 구현
3. 실행 가능한 완전한 EKS 인프라 제공

질문에 대한 답변을 기다리고 있습니다!
