# AWS EKS Terraform 프로젝트

Terraform을 사용하여 AWS EKS(Elastic Kubernetes Service) 클러스터를 **모듈화된 구조**로 배포하는 프로젝트입니다.

이 문서는 실제 배포 경험을 바탕으로 작성되었으며, 발생 가능한 문제와 해결 방법을 포함합니다.

---

## 📋 목차

- [프로젝트 개요](#-프로젝트-개요)
- [핵심 개념](#-핵심-개념)
- [디렉토리 구조](#-디렉토리-구조)
- [아키텍처](#-아키텍처)
- [사전 요구사항](#-사전-요구사항)
- [배포 가이드](#-배포-가이드)
- [문제 해결](#-문제-해결)
- [보안 가이드](#-보안-가이드)
- [비용 관리](#-비용-관리)
- [정리](#-정리)

---

## 🎯 프로젝트 개요

### 주요 특징

- **모듈화된 Terraform 코드**: 재사용 가능한 5개의 모듈
- **Production-ready EKS 클러스터**: 고가용성 및 보안 Best Practice 적용
- **완전한 네트워킹**: VPC, 서브넷, NAT Gateway, 라우팅
- **자동화된 노드 관리**: Managed Node Group with Auto Scaling
- **안전한 State 관리**: S3 + DynamoDB로 State Lock 구현

### 구성

- **EKS 버전**: 1.31
- **리전**: ap-northeast-2 (서울)
- **VPC CIDR**: 10.100.0.0/16
- **가용 영역**: 2개 (ap-northeast-2a, ap-northeast-2c)
- **노드 타입**: t3.medium (2 vCPU, 4GB RAM)
- **노드 수**: 최소 2, 최대 2

---

## 💡 핵심 개념

### 1. 왜 3개 디렉토리로 나눴나?

```
terraform_test/
├── bootstrap/        # Backend 리소스 생성 (일회성)
├── modules/         # 재사용 가능한 컴포넌트
└── environments/    # 실제 환경별 설정
```

#### Bootstrap
- **역할**: S3와 DynamoDB를 생성하여 Terraform Backend 준비
- **특징**: backend 설정 없이 로컬 state 사용
- **실행**: 프로젝트 시작 시 한 번만 실행

#### Modules
- **역할**: VPC, IAM, EKS 등 재사용 가능한 "레고 블록"
- **특징**: 실제 값 없이 로직과 템플릿만 정의
- **장점**: dev, stage, prod 어디서든 같은 코드를 다른 값으로 재사용

#### Environments
- **역할**: modules를 조합하여 실제 인프라 구성
- **특징**: 구체적인 값들(terraform.tfvars)을 제공
- **확장성**: 새 환경 추가 시 디렉토리만 복사하면 됨

### 2. Backend와 State Lock

#### Backend (S3)
```
역할: Terraform State를 "어디에 저장할지" 결정
장점: 팀원들과 State 공유, 로컬 파일 손실 방지
```

#### State Lock (DynamoDB)
```
역할: 동시 apply 방지
동작:
  1. terraform apply 시작 → DynamoDB에 Lock 생성 🔒
  2. 다른 사람이 apply 시도 → "Lock 걸려있음!" 오류 ❌
  3. apply 완료 → Lock 해제 🔓
```

**실제 경험**: 작업 중단 시 Lock이 남아있어 `terraform force-unlock` 필요

### 3. Terraform Import

```
배포(apply): Terraform 코드 → AWS에 리소스 생성
Import:      AWS에 이미 존재하는 리소스 → Terraform State에 등록
```

**실제 경험**: apply 중단 후 일부 리소스가 AWS에만 존재하여 import 필요

---

## 📁 디렉토리 구조

```
terraform_test/
├── bootstrap/                    # Backend 리소스 생성용
│   ├── main.tf                  # S3 버킷, DynamoDB 테이블 정의
│   ├── variables.tf
│   └── outputs.tf
├── modules/                      # 재사용 가능한 모듈
│   ├── vpc/                     # VPC 및 네트워킹
│   ├── iam/                     # IAM 역할 및 정책
│   ├── security-group/          # 보안 그룹
│   ├── eks-cluster/             # EKS 클러스터 & Addons
│   └── eks-node-group/          # EKS 노드 그룹
├── environments/                 # 환경별 설정
│   └── prod/                    # Production 환경
│       ├── main.tf              # 모듈 조합
│       ├── variables.tf         # 변수 정의
│       ├── terraform.tfvars     # 변수 값 (Git 제외!)
│       ├── outputs.tf           # 출력 값
│       ├── providers.tf         # Provider 설정
│       └── backend.tf           # Backend 설정 (Git 제외!)
└── README.md                    # 이 파일
```

---

## 🏗️ 아키텍처

```
┌─────────────────────────────────────────────────────────────┐
│                        AWS Region                           │
│                    ap-northeast-2                           │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐  │
│  │                  VPC (10.100.0.0/16)                │  │
│  │                                                      │  │
│  │  ┌─────────────────────┬─────────────────────┐     │  │
│  │  │   AZ-2a             │   AZ-2c             │     │  │
│  │  │                     │                     │     │  │
│  │  │  ┌──────────────┐   │  ┌──────────────┐  │     │  │
│  │  │  │ Public       │   │  │ Public       │  │     │  │
│  │  │  │ 10.100.1/24  │   │  │ 10.100.2/24  │  │     │  │
│  │  │  │              │   │  │              │  │     │  │
│  │  │  │ NAT Gateway  │   │  │ NAT Gateway  │  │     │  │
│  │  │  └──────────────┘   │  └──────────────┘  │     │  │
│  │  │                     │                     │     │  │
│  │  │  ┌──────────────┐   │  ┌──────────────┐  │     │  │
│  │  │  │ Private      │   │  │ Private      │  │     │  │
│  │  │  │ 10.100.11/24 │   │  │ 10.100.12/24 │  │     │  │
│  │  │  │              │   │  │              │  │     │  │
│  │  │  │ EKS Nodes    │   │  │ EKS Nodes    │  │     │  │
│  │  │  └──────────────┘   │  └──────────────┘  │     │  │
│  │  └─────────────────────┴─────────────────────┘     │  │
│  │                                                      │  │
│  │              EKS Control Plane                      │  │
│  │         (AWS Managed, Multi-AZ)                     │  │
│  └─────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## ✅ 사전 요구사항

1. **AWS CLI**: 설치 및 구성 완료
   ```bash
   aws --version
   aws configure list
   ```

2. **Terraform**: 버전 1.0 이상
   ```bash
   terraform version
   ```

3. **kubectl**: Kubernetes CLI
   ```bash
   kubectl version --client
   ```

4. **AWS IAM 권한**: 다음 서비스에 대한 권한 필요
   - VPC, EC2, EKS
   - IAM (역할 및 정책)
   - S3, DynamoDB (Backend용)
   - CloudWatch Logs

---

## 🚀 배포 가이드

### 1단계: Bootstrap - Backend 리소스 생성

Terraform State를 저장할 S3 버킷과 DynamoDB 테이블을 생성합니다.

```bash
# bootstrap 디렉토리로 이동
cd bootstrap

# Terraform 초기화
terraform init

# 실행 계획 확인
terraform plan

# 리소스 생성
terraform apply

# 출력 확인
terraform output backend_config
```

**생성되는 리소스:**
- S3 버킷: `eks-terraform-state-<AWS-ACCOUNT-ID>` (암호화, 버전 관리, 퍼블릭 액세스 차단)
- DynamoDB 테이블: `eks-terraform-state-lock` (State Lock용)

### 2단계: Backend 설정 확인

`environments/prod/backend.tf` 파일에 올바른 계정 ID가 설정되어 있는지 확인:

```hcl
terraform {
  backend "s3" {
    bucket         = "eks-terraform-state-912542578074"  # 본인의 계정 ID 확인
    key            = "prod/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "eks-terraform-state-lock"
    encrypt        = true
  }
}
```

### 3단계: EKS 클러스터 배포

```bash
# prod 환경 디렉토리로 이동
cd ../environments/prod

# Terraform 초기화 (Backend 연결)
terraform init

# 실행 계획 확인
terraform plan

# 리소스 생성 (약 15-20분 소요)
terraform apply
```

**배포 순서:**
1. VPC & 네트워킹 (약 2-3분)
2. IAM Roles & Policies (약 1분)
3. EKS Cluster (약 10분) ⏰
4. EKS Addons: vpc-cni, kube-proxy (각 1-2분)
5. Node Group (약 3-5분)

### 4단계: kubectl 설정

```bash
# kubeconfig 업데이트
aws eks update-kubeconfig --region ap-northeast-2 --name eks-cluster

# 클러스터 확인
kubectl get nodes

# 예상 출력:
# NAME                                              STATUS   ROLES    AGE   VERSION
# ip-10-100-11-97.ap-northeast-2.compute.internal   Ready    <none>   3m    v1.31.13-eks-ecaa3a6
# ip-10-100-12-46.ap-northeast-2.compute.internal   Ready    <none>   3m    v1.31.13-eks-ecaa3a6

# 전체 Pod 확인
kubectl get pods -A
```

---

## 🐛 문제 해결

### 실제 발생한 문제와 해결책

#### 문제 1: CoreDNS Addon 무한 대기

**증상:**
```
module.eks_cluster.aws_eks_addon.coredns[0]: Still creating... [10m0s elapsed]
```

**원인:**
- CoreDNS는 **워커 노드에서 실행되는 Pod**
- Node Group보다 먼저 설치되어 Pod을 배포할 노드가 없음
- 결과: CoreDNS가 완료되지 않아 Node Group도 시작 안 됨 → **무한 대기**

**해결책 1**: CoreDNS를 나중에 설치
```bash
# 1. terraform.tfvars에서 coredns 임시 제거
enabled_addons = ["vpc-cni", "kube-proxy"]  # coredns 제외

# 2. Node Group 먼저 생성
terraform apply

# 3. coredns 다시 추가
enabled_addons = ["vpc-cni", "kube-proxy", "coredns"]

# 4. 다시 apply
terraform apply
```

**해결책 2**: 이미 생성된 addon import
```bash
# AWS에 이미 addon이 존재하는 경우
terraform import 'module.eks_cluster.aws_eks_addon.coredns[0]' eks-cluster:coredns
terraform import 'module.eks_cluster.aws_eks_addon.kube_proxy[0]' eks-cluster:kube-proxy

terraform apply
```

#### 문제 2: State Lock 오류

**증상:**
```
Error: Error acquiring the state lock
Lock ID: 73cf965d-b1f9-f9b9-91ca-2c2502b560b7
```

**원인:**
- 이전 terraform apply가 비정상 종료됨 (Ctrl+C, 강제 중단 등)
- DynamoDB의 Lock이 해제되지 않고 남아있음

**해결책:**
```bash
# Lock 강제 해제
terraform force-unlock 73cf965d-b1f9-f9b9-91ca-2c2502b560b7

# 다시 apply
terraform apply
```

#### 문제 3: Addon Already Exists

**증상:**
```
Error: creating EKS Add-On (eks-cluster:kube-proxy):
Addon already exists
```

**원인:**
- apply 중단으로 AWS에는 리소스가 생성되었지만 Terraform state에는 기록 안 됨

**해결책:**
```bash
# 현재 AWS의 addon 확인
aws eks list-addons --cluster-name eks-cluster --region ap-northeast-2

# Terraform state로 import
terraform import 'module.eks_cluster.aws_eks_addon.kube_proxy[0]' eks-cluster:kube-proxy

# 다시 apply
terraform apply
```

### 일반적인 문제

#### Backend 초기화 실패

**해결:**
```bash
# 1. AWS 자격 증명 확인
aws sts get-caller-identity

# 2. S3 버킷 존재 확인
aws s3 ls | grep terraform-state

# 3. DynamoDB 테이블 확인
aws dynamodb list-tables --region ap-northeast-2 | grep terraform-state-lock

# 4. backend.tf 설정 재확인
cat environments/prod/backend.tf
```

#### kubectl 접근 불가

**해결:**
```bash
# kubeconfig 재설정
aws eks update-kubeconfig --region ap-northeast-2 --name eks-cluster

# AWS 자격 증명 확인
aws sts get-caller-identity

# 클러스터 상태 확인
aws eks describe-cluster --name eks-cluster --region ap-northeast-2
```

---

## 🔐 보안 가이드

### ⚠️ 절대 Git에 커밋하면 안 되는 파일

```
❌ terraform.tfstate         # 모든 인프라 정보 포함
❌ terraform.tfvars          # 실제 설정 값
❌ backend.tf                # AWS 계정 ID 포함
❌ *.pem, *.key             # AWS 자격 증명
❌ kubeconfig               # 클러스터 접근 정보
```

### ✅ Git에 커밋해야 하는 파일

```
✅ *.tf (backend.tf 제외)
✅ *.example
✅ modules/**/*
✅ README.md
✅ .gitignore
```

### 보안 체크리스트

```bash
# 민감한 파일이 Git에 추적되는지 확인 (결과 없어야 함)
git ls-files | grep -E "terraform.tfvars$|backend.tf$"

# .gitignore 동작 확인
git check-ignore -v environments/prod/terraform.tfvars
git check-ignore -v environments/prod/backend.tf
```

### AWS 키 노출 시 대응

```bash
# 1. 즉시 키 비활성화
aws iam update-access-key --access-key-id EXPOSED_KEY_ID --status Inactive

# 2. 새 키 생성
aws iam create-access-key --user-name YOUR_USER

# 3. 노출된 키 삭제
aws iam delete-access-key --access-key-id EXPOSED_KEY_ID --user-name YOUR_USER
```

---

## 💰 비용 관리

### 예상 비용 (월)

| 리소스 | 수량 | 예상 비용 (월) |
|--------|------|----------------|
| EKS Control Plane | 1 | $73 |
| EC2 (t3.medium) | 2 | $60 |
| NAT Gateway | 2 | $65 |
| EBS (20GB) | 2 | $2 |
| CloudWatch Logs | - | $5 |
| **총 예상 비용** | - | **약 $205/월** |

### 비용 절감 팁

1. **NAT Gateway를 1개로 줄이기**: -$32.5/월
   ```hcl
   # terraform.tfvars
   enable_nat_gateway = false  # 또는 1개만 생성하도록 수정
   ```

2. **로깅 비활성화**: -$5/월
   ```hcl
   enabled_log_types = []
   ```

3. **Spot 인스턴스 사용**: -$40/월
   ```hcl
   capacity_type = "SPOT"
   ```

4. **사용하지 않을 때 삭제**:
   ```bash
   terraform destroy
   ```

---

## 🧹 정리 (완전 삭제 가이드)

### 순서가 중요합니다!

**삭제 순서**:
1. EKS 인프라 (environments/prod)
2. Backend 리소스 (bootstrap)

**잘못된 순서로 삭제 시**: State 파일이 S3에 있는데 S3를 먼저 삭제하면 문제 발생

### 1단계: EKS 인프라 삭제

```bash
cd environments/prod

# 삭제 계획 확인
terraform plan -destroy

# 인프라 삭제 (10-15분 소요)
terraform destroy -auto-approve
```

**삭제되는 리소스 (총 32개)**:
- EKS 클러스터
- Worker 노드 그룹
- EKS Addons (CoreDNS, kube-proxy, vpc-cni)
- VPC, 서브넷, NAT Gateway (삭제 시간 오래 걸림)
- Internet Gateway
- 라우팅 테이블
- Elastic IP
- IAM 역할 및 정책

**확인**:
```bash
# State가 비었는지 확인
terraform state list

# AWS에서 실제 삭제 확인
aws eks list-clusters --region ap-northeast-2
aws ec2 describe-vpcs --region ap-northeast-2 --filters "Name=tag:Name,Values=eks-vpc"
```

### 2단계: Backend 리소스 삭제

**⚠️ 주의**:
- State 파일이 완전히 손실됩니다
- 이 단계는 프로젝트를 완전히 제거할 때만 실행하세요

#### 문제 발생: S3 버킷이 비어있지 않음

```bash
cd ../../bootstrap
terraform destroy -auto-approve
```

**예상 에러**:
```
Error: deleting S3 Bucket: BucketNotEmpty
The bucket you tried to delete is not empty.
You must delete all versions in the bucket.
```

#### 해결 방법: S3 버킷 버전 수동 삭제

**1. 모든 객체 버전 삭제**:
```bash
aws s3api delete-objects \
  --bucket eks-terraform-state-912542578074 \
  --delete "$(aws s3api list-object-versions \
    --bucket eks-terraform-state-912542578074 \
    --query '{Objects: Versions[].{Key:Key,VersionId:VersionId}}' \
    --max-items 1000)"
```

**2. 삭제 마커 제거**:
```bash
aws s3api delete-objects \
  --bucket eks-terraform-state-912542578074 \
  --delete "$(aws s3api list-object-versions \
    --bucket eks-terraform-state-912542578074 \
    --query '{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}')"
```

**3. Terraform destroy 재시도**:
```bash
# DynamoDB가 이미 삭제되어 Lock 에러 발생 시 -lock=false 사용
terraform destroy -auto-approve -lock=false
```

**4. S3 버킷 수동 삭제** (여전히 남아있는 경우):
```bash
# 마지막 버전 삭제
aws s3api delete-object \
  --bucket eks-terraform-state-912542578074 \
  --key prod/terraform.tfstate \
  --version-id null

# 버킷 삭제
aws s3 rb s3://eks-terraform-state-912542578074
```

### 최종 확인

**모든 리소스가 삭제되었는지 확인**:

```bash
echo "=== EKS 클러스터 ==="
aws eks list-clusters --region ap-northeast-2

echo "=== NAT Gateway (Active만) ==="
aws ec2 describe-nat-gateways --region ap-northeast-2 \
  --filter "Name=state,Values=available" \
  --query 'NatGateways[*].NatGatewayId'

echo "=== S3 버킷 ==="
aws s3 ls | grep eks-terraform-state

echo "=== DynamoDB 테이블 ==="
aws dynamodb list-tables | grep eks-terraform-state-lock
```

**예상 결과**:
- EKS 클러스터: `[]` (빈 배열)
- NAT Gateway: 출력 없음 (deleted 상태는 한동안 보임, 정상)
- S3 버킷: 출력 없음
- DynamoDB: 출력 없음

### AWS 콘솔에서 확인 시 주의사항

**AWS 콘솔은 삭제된 리소스를 한동안 보여줍니다**:
- NAT Gateway: `deleted` 상태로 표시됨
- EC2 인스턴스: `terminated` 상태로 표시됨
- VPC: 삭제되면 목록에서 사라짐

**비용이 청구되는 리소스**: `available`, `running` 등 **활성** 상태만
**비용 청구 안됨**: `deleted`, `terminated` 상태

**필터 설정**:
- EC2 콘솔 → NAT Gateways → Filter by State → "Available"만 선택
- 이렇게 하면 실제 비용 청구되는 리소스만 보임

### 수동 정리가 필요한 리소스

Terraform으로 관리하지 않는 리소스들:
- CloudWatch Logs 로그 그룹
- ENI (Elastic Network Interface) - 자동 삭제됨
- 로드 밸런서 (직접 생성한 경우)

### 비용 절감 확인

삭제 전후 비용 비교:
- **삭제 전**: 월 $205 (EKS $73 + NAT $90 + EC2 $42)
- **삭제 후**: $0

---

## 📚 참고 자료

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [EKS User Guide](https://docs.aws.amazon.com/eks/latest/userguide/)
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)
- [Terraform S3 Backend](https://www.terraform.io/docs/language/settings/backends/s3.html)

---

## 🎓 학습 포인트

이 프로젝트를 통해 배운 내용:

1. **모듈화의 중요성**: 재사용 가능한 코드로 효율성 향상
2. **Backend와 State Lock**: 팀 협업을 위한 필수 개념
3. **의존성 관리**: 리소스 생성 순서가 중요함 (CoreDNS 문제)
4. **Terraform Import**: 기존 리소스를 State에 등록하는 방법
5. **보안**: 민감한 정보를 Git에서 분리하는 방법
6. **문제 해결**: 실제 발생 가능한 문제와 대응 방법

---

## 👥 팀

- **Environment**: prod
- **Project**: eks-project
- **Team**: Team Domodachi

---

**생성일**: 2025-11-21
**Terraform 버전**: >= 1.0
**AWS Provider 버전**: ~> 5.0
**EKS 버전**: 1.31

**마지막 업데이트**: 2025-11-21
