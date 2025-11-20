# 🚀 빠른 시작 가이드 (보안 중심)

## ⚠️ 시작하기 전에

**절대 Git에 커밋하면 안 되는 파일들:**

```
❌ environments/prod/terraform.tfvars
❌ environments/prod/backend.tf
❌ *.tfstate
❌ kubeconfig
❌ *.pem, *.key
```

---

## 📋 1단계: 보안 설정 (필수!)

### 자동 설정 (추천)

```bash
# 보안 설정 스크립트 실행
./setup-security.sh
```

### 수동 설정

```bash
# 1. 예제 파일 복사
cp environments/prod/terraform.tfvars.example environments/prod/terraform.tfvars
cp environments/prod/backend.tf.example environments/prod/backend.tf

# 2. 파일 권한 설정 (Linux/Mac)
chmod 600 environments/prod/terraform.tfvars
chmod 600 environments/prod/backend.tf
```

---

## 🔧 2단계: 설정 파일 수정

### AWS 계정 ID 확인

```bash
aws sts get-caller-identity --query Account --output text
```

### terraform.tfvars 수정

`environments/prod/terraform.tfvars` 파일을 열어서 필요한 값 수정:

```hcl
# 최소한 다음 값들을 확인하세요
cluster_name = "my-eks-cluster"      # 원하는 이름으로 변경
aws_region   = "ap-northeast-2"      # 리전 확인

# 나머지는 기본값 사용 가능
```

### backend.tf 수정

`environments/prod/backend.tf` 파일을 열어서 계정 ID 수정:

```hcl
terraform {
  backend "s3" {
    # YOUR_AWS_ACCOUNT_ID를 실제 계정 ID로 변경
    bucket = "eks-terraform-state-123456789012"
    # ...
  }
}
```

---

## 🏗️ 3단계: Backend 리소스 생성

```bash
# bootstrap 디렉토리로 이동
cd bootstrap

# 초기화
terraform init

# 실행 계획 확인
terraform plan

# 리소스 생성
terraform apply

# 출력 확인 (backend 설정 정보)
terraform output backend_config

# 프로젝트 루트로 돌아오기
cd ..
```

---

## 🚀 4단계: EKS 클러스터 배포

```bash
# prod 환경으로 이동
cd environments/prod

# 초기화 (Backend 연결)
terraform init

# 실행 계획 확인 (중요!)
terraform plan

# 클러스터 생성 (15-20분 소요)
terraform apply

# 완료 후 출력 확인
terraform output
```

---

## 🎯 5단계: kubectl 설정

```bash
# kubeconfig 업데이트
aws eks update-kubeconfig --region ap-northeast-2 --name eks-cluster

# 클러스터 확인
kubectl get nodes
kubectl get pods -A

# 클러스터 정보 확인
kubectl cluster-info
```

---

## 🔍 Git 보안 체크리스트

배포 전 반드시 확인:

```bash
# 1. Git 상태 확인
git status

# 2. 추적되지 않는 파일 확인 (민감한 파일이 있어야 함)
git status --ignored

# 3. 민감한 파일이 Git에 추적되는지 확인 (결과가 없어야 함)
git ls-files | grep -E "terraform.tfvars$|backend.tf$"

# 4. .gitignore가 제대로 작동하는지 확인
git check-ignore -v environments/prod/terraform.tfvars
git check-ignore -v environments/prod/backend.tf
```

**예상 결과:**
```
.gitignore:15:*.tfvars    environments/prod/terraform.tfvars
.gitignore:24:**/backend.tf    environments/prod/backend.tf
```

---

## 🧹 정리 (비용 절감)

### 전체 인프라 삭제

```bash
# prod 환경으로 이동
cd environments/prod

# 삭제 계획 확인
terraform plan -destroy

# 인프라 삭제
terraform destroy

# 확인 후 'yes' 입력
```

### Backend 리소스 삭제 (선택적)

**⚠️ 주의: State 파일이 손실됩니다!**

```bash
cd ../../bootstrap
terraform destroy
```

---

## 🆘 문제 해결

### 문제 1: terraform.tfvars를 Git에 커밋했어요!

```bash
# 아직 푸시하지 않았다면
git rm --cached environments/prod/terraform.tfvars
git commit --amend

# .gitignore 확인
git check-ignore -v environments/prod/terraform.tfvars
```

### 문제 2: Backend 초기화 실패

```bash
# 1. AWS 자격 증명 확인
aws sts get-caller-identity

# 2. S3 버킷 존재 확인
aws s3 ls | grep terraform-state

# 3. DynamoDB 테이블 확인
aws dynamodb list-tables | grep terraform-state-lock

# 4. backend.tf 설정 재확인
cat environments/prod/backend.tf
```

### 문제 3: kubectl 접근 불가

```bash
# 1. kubeconfig 재생성
aws eks update-kubeconfig --region ap-northeast-2 --name eks-cluster

# 2. AWS 자격 증명 확인
aws sts get-caller-identity

# 3. 클러스터 상태 확인
aws eks describe-cluster --name eks-cluster --region ap-northeast-2 --query "cluster.status"
```

---

## 📁 파일 구조 요약

```
terraform_test/
├── .gitignore                          ✅ 커밋
├── README.md                           ✅ 커밋
├── SECURITY.md                         ✅ 커밋
├── setup-security.sh                   ✅ 커밋
├── bootstrap/                          ✅ 커밋
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── modules/                            ✅ 커밋
│   ├── vpc/
│   ├── iam/
│   ├── security-group/
│   ├── eks-cluster/
│   └── eks-node-group/
└── environments/
    └── prod/
        ├── main.tf                     ✅ 커밋
        ├── variables.tf                ✅ 커밋
        ├── outputs.tf                  ✅ 커밋
        ├── providers.tf                ✅ 커밋
        ├── terraform.tfvars.example    ✅ 커밋
        ├── backend.tf.example          ✅ 커밋
        ├── terraform.tfvars            ❌ 절대 커밋 금지!
        └── backend.tf                  ❌ 절대 커밋 금지!
```

---

## 📚 추가 문서

- **[SECURITY.md](SECURITY.md)**: 민감한 정보 관리 상세 가이드
- **[BACKEND_SETUP.md](BACKEND_SETUP.md)**: Backend 설정 상세 가이드
- **[README.md](README.md)**: 전체 프로젝트 문서

---

## 💡 팁

### 환경 변수 사용

```bash
# AWS 자격 증명 (권장)
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"
export AWS_DEFAULT_REGION="ap-northeast-2"

# Terraform 변수
export TF_VAR_cluster_name="my-cluster"

# 적용
terraform apply
```

### 비용 절감

- **NAT Gateway 1개만 사용**: terraform.tfvars에서 수정
- **Spot 인스턴스 사용**: `capacity_type = "SPOT"`
- **로깅 비활성화**: `enabled_log_types = []`
- **사용하지 않을 때 삭제**: `terraform destroy`

### 여러 환경 관리

```bash
# dev 환경
cd environments/dev
terraform init
terraform apply

# prod 환경
cd ../prod
terraform init
terraform apply
```

---

**마지막 업데이트**: 2025-11-20
