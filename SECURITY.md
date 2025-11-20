# 🔐 민감한 정보 관리 가이드

Terraform 프로젝트에서 민감한 정보를 안전하게 관리하는 방법입니다.

---

## ⚠️ 절대 Git에 커밋하면 안 되는 파일

다음 파일들은 **절대로** Git에 커밋하면 안 됩니다:

### 1. State 파일 (`.tfstate`)
```
❌ terraform.tfstate
❌ terraform.tfstate.backup
❌ *.tfstate.*
```
**이유**: AWS 리소스 ID, IP 주소, 비밀번호 등 모든 인프라 정보 포함

### 2. 변수 파일 (`.tfvars`)
```
❌ terraform.tfvars
❌ *.auto.tfvars
❌ secrets.tfvars
```
**이유**: 실제 설정 값, 계정 정보 포함

### 3. Backend 설정 (`.tf`)
```
❌ backend.tf
```
**이유**: AWS 계정 ID, S3 버킷 이름 포함

### 4. AWS 자격 증명
```
❌ *.pem
❌ *.key
❌ credentials
❌ .aws/credentials
```
**이유**: AWS 액세스 키, 비밀 키 포함

### 5. Kubernetes 설정
```
❌ kubeconfig
❌ *.kubeconfig
```
**이유**: 클러스터 접근 정보, 인증서 포함

---

## ✅ Git에 커밋해야 하는 파일

다음 파일들은 **반드시** Git에 커밋해야 합니다:

### 1. 예제 파일
```
✅ terraform.tfvars.example
✅ backend.tf.example
✅ .env.example
```
**이유**: 팀원들이 참고할 템플릿

### 2. 모듈 파일
```
✅ modules/**/*.tf
✅ modules/**/variables.tf
✅ modules/**/outputs.tf
```
**이유**: 재사용 가능한 인프라 코드

### 3. 환경별 설정
```
✅ environments/**/main.tf
✅ environments/**/variables.tf
✅ environments/**/outputs.tf
✅ environments/**/providers.tf
```
**이유**: 인프라 구조 정의 (값은 제외)

### 4. 문서
```
✅ README.md
✅ *.md
```
**이유**: 프로젝트 문서화

---

## 🚀 초기 설정 가이드

### 1단계: 예제 파일 복사

```bash
# terraform.tfvars 생성
cp environments/prod/terraform.tfvars.example environments/prod/terraform.tfvars

# backend.tf 생성
cp environments/prod/backend.tf.example environments/prod/backend.tf
```

### 2단계: 실제 값 입력

**terraform.tfvars** 파일 수정:
```hcl
# 예제 값을 실제 값으로 변경
aws_region = "ap-northeast-2"
cluster_name = "my-prod-cluster"  # 실제 클러스터 이름
```

**backend.tf** 파일 수정:
```hcl
terraform {
  backend "s3" {
    # YOUR_AWS_ACCOUNT_ID를 실제 계정 ID로 변경
    bucket = "eks-terraform-state-123456789012"
    # ...
  }
}
```

### 3단계: 파일 권한 설정 (Linux/Mac)

```bash
# 민감한 파일의 권한을 제한
chmod 600 environments/prod/terraform.tfvars
chmod 600 environments/prod/backend.tf
```

---

## 🔍 실수로 커밋한 경우

### 민감한 파일이 아직 푸시되지 않은 경우

```bash
# 특정 파일을 커밋에서 제거
git rm --cached environments/prod/terraform.tfvars
git commit --amend

# 또는 마지막 커밋 전체 취소
git reset HEAD~1
```

### 이미 푸시한 경우 (🚨 위험!)

```bash
# 1. Git 히스토리에서 완전히 제거
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch environments/prod/terraform.tfvars" \
  --prune-empty --tag-name-filter cat -- --all

# 2. 강제 푸시 (주의: 협업 시 팀원과 협의 필요)
git push origin --force --all

# 3. AWS 자격 증명이 노출된 경우 즉시 변경!
aws iam create-access-key --user-name YOUR_USER
aws iam delete-access-key --access-key-id OLD_KEY_ID --user-name YOUR_USER
```

**더 안전한 방법**: [BFG Repo-Cleaner](https://rtyley.github.io/bfg-repo-cleaner/) 사용

---

## 🛡️ 환경 변수 사용 (권장)

민감한 값을 환경 변수로 관리하는 방법:

### 방법 1: 직접 설정

```bash
# AWS 자격 증명
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="ap-northeast-2"

# Terraform 변수
export TF_VAR_cluster_name="my-cluster"
export TF_VAR_aws_region="ap-northeast-2"
```

### 방법 2: .env 파일 사용

**.env 파일** 생성 (gitignore에 포함):
```bash
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_DEFAULT_REGION=ap-northeast-2
TF_VAR_cluster_name=my-cluster
```

사용:
```bash
# .env 파일 로드
source .env

# 또는 direnv 사용
direnv allow
```

---

## 🔐 Secrets 관리 도구

### 1. AWS Secrets Manager

```bash
# Secret 생성
aws secretsmanager create-secret \
  --name terraform/eks-cluster \
  --secret-string '{"db_password":"mypassword"}'

# Secret 조회
aws secretsmanager get-secret-value \
  --secret-id terraform/eks-cluster
```

Terraform에서 사용:
```hcl
data "aws_secretsmanager_secret_version" "db" {
  secret_id = "terraform/eks-cluster"
}

locals {
  db_password = jsondecode(data.aws_secretsmanager_secret_version.db.secret_string)["db_password"]
}
```

### 2. HashiCorp Vault

```bash
# Vault에 저장
vault kv put secret/terraform cluster_name=my-cluster

# Terraform에서 사용
data "vault_generic_secret" "cluster" {
  path = "secret/terraform"
}
```

### 3. SOPS (Secrets OPerationS)

```bash
# 파일 암호화
sops --encrypt secrets.yaml > secrets.enc.yaml

# 파일 복호화
sops --decrypt secrets.enc.yaml > secrets.yaml
```

---

## 📋 체크리스트

배포 전 다음 사항을 확인하세요:

- [ ] `.gitignore` 파일이 존재하고 올바르게 설정됨
- [ ] `terraform.tfvars` 파일이 `.gitignore`에 포함됨
- [ ] `backend.tf` 파일이 `.gitignore`에 포함됨
- [ ] 예제 파일 (`*.example`)이 생성됨
- [ ] AWS 자격 증명이 환경 변수로 설정됨
- [ ] State 파일이 S3에 안전하게 저장됨
- [ ] Git 히스토리에 민감한 정보가 없음

확인 명령:
```bash
# .gitignore 동작 확인
git status --ignored

# Git에 추적되지 않는 파일 확인
git ls-files --others

# 민감한 파일이 커밋되었는지 확인
git log --all --full-history -- "*.tfvars"
```

---

## 🚨 보안 사고 대응

### 1. AWS 키가 노출된 경우

```bash
# 1. 즉시 키 비활성화
aws iam update-access-key \
  --access-key-id EXPOSED_KEY_ID \
  --status Inactive

# 2. 새 키 생성
aws iam create-access-key --user-name YOUR_USER

# 3. 노출된 키 삭제
aws iam delete-access-key \
  --access-key-id EXPOSED_KEY_ID

# 4. CloudTrail 로그 확인 (악용 여부 확인)
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=AccessKeyId,AttributeValue=EXPOSED_KEY_ID
```

### 2. GitHub에 푸시된 경우

1. **즉시 키 변경** (위 절차 참고)
2. **GitHub에 알림**: [GitHub Token Scanning](https://docs.github.com/en/code-security/secret-scanning/about-secret-scanning)
3. **Git 히스토리 정리**: BFG Repo-Cleaner 사용
4. **팀원에게 알림**: 새 키로 업데이트 필요

### 3. 의심스러운 활동 감지

```bash
# 최근 API 호출 확인
aws cloudtrail lookup-events --max-items 100

# 활성 세션 확인
aws sts get-caller-identity

# 리소스 변경사항 확인
aws config get-resource-config-history \
  --resource-type AWS::EC2::Instance \
  --resource-id i-1234567890abcdef0
```

---

## 📚 참고 자료

- [Terraform Security Best Practices](https://developer.hashicorp.com/terraform/tutorials/configuration-language/sensitive-variables)
- [AWS Security Best Practices](https://aws.amazon.com/security/security-learning/)
- [OWASP Secrets Management Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)
- [GitHub Secret Scanning](https://docs.github.com/en/code-security/secret-scanning)

---

## ❓ FAQ

### Q: terraform.tfvars를 팀원과 공유하려면?

**A**: 절대 Git에 커밋하지 마세요. 대신:
- AWS Secrets Manager 사용
- 암호화된 채널로 전송 (1Password, LastPass)
- 회사 내부 보안 저장소 사용

### Q: State 파일은 왜 민감한가요?

**A**: State 파일에는 다음이 포함됩니다:
- 리소스 ID
- IP 주소
- 비밀번호 (outputs)
- 인증서
- 모든 리소스 구성

### Q: .terraform 디렉토리는?

**A**: 플러그인과 모듈이 저장됩니다. `.gitignore`에 포함되어야 하지만 민감한 정보는 없습니다.

### Q: backend.tf는 왜 Git에 커밋하면 안 되나요?

**A**: 다음 정보가 포함됩니다:
- AWS 계정 ID
- S3 버킷 이름
- DynamoDB 테이블 이름

이 정보로 공격자가 인프라를 추측할 수 있습니다.

---

**마지막 업데이트**: 2025-11-20
**작성자**: Team Domodachi
