#!/bin/bash

# 민감한 정보 보호를 위한 초기 설정 스크립트
# 이 스크립트는 프로젝트를 처음 클론하거나 설정할 때 실행하세요

set -e

echo "🔐 Terraform 프로젝트 보안 설정 시작..."
echo ""

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 현재 디렉토리 확인
if [ ! -f "README.md" ] || [ ! -d "modules" ]; then
    echo -e "${RED}❌ 오류: 프로젝트 루트 디렉토리에서 실행해주세요${NC}"
    exit 1
fi

echo "📁 프로젝트 루트 디렉토리 확인됨"
echo ""

# 1. 예제 파일 복사
echo "📋 1단계: 예제 파일 복사 중..."

if [ ! -f "environments/prod/terraform.tfvars" ]; then
    if [ -f "environments/prod/terraform.tfvars.example" ]; then
        cp environments/prod/terraform.tfvars.example environments/prod/terraform.tfvars
        echo -e "${GREEN}✓ terraform.tfvars 생성됨${NC}"
    else
        echo -e "${YELLOW}⚠ terraform.tfvars.example 파일이 없습니다${NC}"
    fi
else
    echo -e "${YELLOW}⚠ terraform.tfvars가 이미 존재합니다${NC}"
fi

if [ ! -f "environments/prod/backend.tf" ]; then
    if [ -f "environments/prod/backend.tf.example" ]; then
        cp environments/prod/backend.tf.example environments/prod/backend.tf
        echo -e "${GREEN}✓ backend.tf 생성됨${NC}"
    else
        echo -e "${YELLOW}⚠ backend.tf.example 파일이 없습니다${NC}"
    fi
else
    echo -e "${YELLOW}⚠ backend.tf가 이미 존재합니다${NC}"
fi

echo ""

# 2. 파일 권한 설정 (Linux/Mac만)
if [[ "$OSTYPE" != "msys" && "$OSTYPE" != "win32" ]]; then
    echo "🔒 2단계: 파일 권한 설정 중..."

    if [ -f "environments/prod/terraform.tfvars" ]; then
        chmod 600 environments/prod/terraform.tfvars
        echo -e "${GREEN}✓ terraform.tfvars 권한 설정 (600)${NC}"
    fi

    if [ -f "environments/prod/backend.tf" ]; then
        chmod 600 environments/prod/backend.tf
        echo -e "${GREEN}✓ backend.tf 권한 설정 (600)${NC}"
    fi

    echo ""
fi

# 3. Git 설정 확인
echo "🔍 3단계: Git 설정 확인 중..."

if [ ! -d ".git" ]; then
    echo -e "${YELLOW}⚠ Git 저장소가 초기화되지 않았습니다${NC}"
    read -p "Git 저장소를 초기화하시겠습니까? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git init
        echo -e "${GREEN}✓ Git 저장소 초기화됨${NC}"
    fi
fi

if [ -d ".git" ]; then
    # 민감한 파일이 Git에 추적되고 있는지 확인
    echo "민감한 파일 추적 상태 확인 중..."

    TRACKED_SENSITIVE_FILES=()

    if git ls-files --error-unmatch "environments/prod/terraform.tfvars" 2>/dev/null; then
        TRACKED_SENSITIVE_FILES+=("environments/prod/terraform.tfvars")
    fi

    if git ls-files --error-unmatch "environments/prod/backend.tf" 2>/dev/null; then
        TRACKED_SENSITIVE_FILES+=("environments/prod/backend.tf")
    fi

    if [ ${#TRACKED_SENSITIVE_FILES[@]} -gt 0 ]; then
        echo -e "${RED}⚠️  경고: 다음 민감한 파일이 Git에 추적되고 있습니다:${NC}"
        for file in "${TRACKED_SENSITIVE_FILES[@]}"; do
            echo -e "${RED}   - $file${NC}"
        done
        echo ""
        read -p "Git 추적에서 제거하시겠습니까? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            for file in "${TRACKED_SENSITIVE_FILES[@]}"; do
                git rm --cached "$file" 2>/dev/null || true
                echo -e "${GREEN}✓ $file Git 추적 제거됨${NC}"
            done
        fi
    else
        echo -e "${GREEN}✓ 민감한 파일이 Git에 추적되지 않습니다${NC}"
    fi
fi

echo ""

# 4. AWS 계정 ID 확인
echo "🔑 4단계: AWS 계정 정보 확인 중..."

if command -v aws &> /dev/null; then
    AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null || echo "")

    if [ -n "$AWS_ACCOUNT_ID" ]; then
        echo -e "${GREEN}✓ AWS 계정 ID: $AWS_ACCOUNT_ID${NC}"
        echo ""
        echo -e "${YELLOW}다음 파일들을 수정해야 합니다:${NC}"
        echo "  1. environments/prod/backend.tf"
        echo "     bucket = \"eks-terraform-state-$AWS_ACCOUNT_ID\""
        echo ""
    else
        echo -e "${YELLOW}⚠ AWS CLI가 구성되지 않았습니다${NC}"
        echo "  aws configure를 실행하여 AWS 자격 증명을 설정하세요"
    fi
else
    echo -e "${YELLOW}⚠ AWS CLI가 설치되지 않았습니다${NC}"
fi

echo ""

# 5. 요약
echo "📊 설정 완료!"
echo ""
echo -e "${GREEN}✅ 완료된 작업:${NC}"
echo "  • 예제 파일 복사"
echo "  • 파일 권한 설정"
echo "  • Git 설정 확인"
echo ""
echo -e "${YELLOW}⚠️  다음 작업을 수행해야 합니다:${NC}"
echo ""
echo "1. environments/prod/terraform.tfvars 파일 수정"
echo "   - 실제 값으로 변경하세요"
echo ""
echo "2. environments/prod/backend.tf 파일 수정"
echo "   - YOUR_AWS_ACCOUNT_ID를 실제 계정 ID로 변경"
if [ -n "$AWS_ACCOUNT_ID" ]; then
    echo "   - bucket = \"eks-terraform-state-$AWS_ACCOUNT_ID\""
fi
echo ""
echo "3. bootstrap 실행 (Backend 리소스 생성)"
echo "   cd bootstrap"
echo "   terraform init"
echo "   terraform apply"
echo ""
echo "4. 자세한 내용은 SECURITY.md 파일을 참고하세요"
echo ""
echo -e "${RED}🚨 중요: terraform.tfvars와 backend.tf를 절대 Git에 커밋하지 마세요!${NC}"
echo ""
