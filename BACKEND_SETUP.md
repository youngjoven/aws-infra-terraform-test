# Terraform Backend 설정 가이드 (S3 + DynamoDB)

## 📋 개요

Terraform State를 로컬이 아닌 S3에 저장하고, DynamoDB로 State Lock을 구현합니다.

### 왜 필요한가?

1. **협업 가능**: 팀원들과 같은 State 공유
2. **State Lock**: 동시에 여러 명이 apply 하는 것 방지
3. **버전 관리**: S3 버전 관리로 State 히스토리 보존
4. **안전성**: 로컬 파일 손실 방지

---

## 🔧 설정 방법

### 1단계: Backend용 리소스 생성

Backend를 사용하기 전에 먼저 S3 버킷과 DynamoDB 테이블을 생성해야 합니다.

#### 방법 A: AWS CLI로 생성 (추천)

```bash
# 1. S3 버킷 생성
aws s3api create-bucket \
  --bucket eks-terraform-state-<YOUR-ACCOUNT-ID> \
  --region ap-northeast-2 \
  --create-bucket-configuration LocationConstraint=ap-northeast-2

# 2. S3 버킷 버전 관리 활성화
aws s3api put-bucket-versioning \
  --bucket eks-terraform-state-<YOUR-ACCOUNT-ID> \
  --versioning-configuration Status=Enabled

# 3. S3 버킷 암호화 활성화
aws s3api put-bucket-encryption \
  --bucket eks-terraform-state-<YOUR-ACCOUNT-ID> \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# 4. S3 버킷 퍼블릭 액세스 차단
aws s3api put-public-access-block \
  --bucket eks-terraform-state-<YOUR-ACCOUNT-ID> \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# 5. DynamoDB 테이블 생성 (State Lock용)
aws dynamodb create-table \
  --table-name eks-terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region ap-northeast-2
```

**참고**: `<YOUR-ACCOUNT-ID>`는 본인의 AWS 계정 ID로 변경하세요.
- 계정 ID 확인: `aws sts get-caller-identity --query Account --output text`

#### 방법 B: Terraform으로 생성 (Bootstrap)

`bootstrap/` 디렉토리에 있는 Terraform 코드를 사용하여 생성:

```bash
cd bootstrap
terraform init
terraform apply
```

---

### 2단계: Backend 설정 파일 작성

`environments/prod/backend.tf` 파일에 다음 내용 추가:

```hcl
terraform {
  backend "s3" {
    bucket         = "eks-terraform-state-<YOUR-ACCOUNT-ID>"
    key            = "prod/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "eks-terraform-state-lock"
    encrypt        = true
  }
}
```

---

### 3단계: Backend 초기화

```bash
cd environments/prod
terraform init
```

Terraform이 로컬 State를 S3로 마이그레이션할지 물어보면 `yes`를 입력합니다.

---

## 🔐 보안 Best Practices

1. **S3 버킷 이름**: 전역적으로 고유해야 하므로 계정 ID 포함
2. **암호화**: 항상 활성화 (AES256 또는 KMS)
3. **버전 관리**: State 히스토리 보존 및 롤백 가능
4. **퍼블릭 액세스 차단**: 외부 접근 완전 차단
5. **DynamoDB 테이블**: PAY_PER_REQUEST 모드로 비용 절감

---

## 💰 비용 예상

- **S3**:
  - 스토리지: ~$0.025/GB/월 (State 파일은 보통 1MB 미만)
  - 요청: GET/PUT 요청당 소액
- **DynamoDB**:
  - PAY_PER_REQUEST 모드: 사용한 만큼만 지불
  - 실제 비용: 월 $1 미만 (소규모 팀)

---

## 🧹 정리 (주의!)

Backend 리소스를 삭제하면 State 파일이 손실됩니다. 반드시 백업 후 삭제하세요.

```bash
# S3 버킷 비우기
aws s3 rm s3://eks-terraform-state-<YOUR-ACCOUNT-ID> --recursive

# S3 버킷 삭제
aws s3api delete-bucket \
  --bucket eks-terraform-state-<YOUR-ACCOUNT-ID> \
  --region ap-northeast-2

# DynamoDB 테이블 삭제
aws dynamodb delete-table \
  --table-name eks-terraform-state-lock \
  --region ap-northeast-2
```

---

## 📚 참고 자료

- [Terraform S3 Backend](https://www.terraform.io/docs/language/settings/backends/s3.html)
- [AWS S3 Versioning](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Versioning.html)
- [DynamoDB State Locking](https://www.terraform.io/docs/language/settings/backends/s3.html#dynamodb-state-locking)
