#!/bin/bash

# Productivity Agents - Configuration Validation Script
# This script validates the configuration files and tests connections

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Configuration paths
CLAUDE_DIR="$HOME/.claude"
CONFIG_FILE="$CLAUDE_DIR/productivity-agents.json"
ENV_FILE="$CLAUDE_DIR/.env"
RETRO_DIR="$CLAUDE_DIR/retrospectives"

# Validation counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

# Validation function
validate_check() {
    local check_name=$1
    local check_command=$2
    local check_type=${3:-error}  # error or warning

    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

    if eval "$check_command" > /dev/null 2>&1; then
        print_success "$check_name"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        return 0
    else
        if [[ "$check_type" == "warning" ]]; then
            print_warning "$check_name"
            WARNING_CHECKS=$((WARNING_CHECKS + 1))
        else
            print_error "$check_name"
            FAILED_CHECKS=$((FAILED_CHECKS + 1))
        fi
        return 1
    fi
}

# Banner
clear
print_header "🔍 설정 검증"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 1: Configuration Files Check
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo "[1/5] 설정 파일 확인..."
echo ""

validate_check "$CONFIG_FILE" "test -f '$CONFIG_FILE'" "error"
validate_check "$ENV_FILE" "test -f '$ENV_FILE'" "warning"

# Check for project settings (warning only)
if [[ -f ".claude/settings.local.json" ]]; then
    validate_check ".claude/settings.local.json" "test -f '.claude/settings.local.json'" "warning"
else
    print_info "프로젝트 설정 없음 (선택 사항)"
fi

echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 2: JSON Schema Validation
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo "[2/5] JSON 스키마 검증..."
echo ""

# Check if jq is available
if command -v jq &> /dev/null; then
    if validate_check "전역 설정 JSON 유효성" "jq empty '$CONFIG_FILE'" "error"; then
        # Additional schema checks
        if jq -e '.atlassian' "$CONFIG_FILE" > /dev/null 2>&1; then
            validate_check "Atlassian 설정 존재" "jq -e '.atlassian.defaultUrl' '$CONFIG_FILE'" "warning"
            validate_check "Atlassian 사용자 정보" "jq -e '.atlassian.user.email' '$CONFIG_FILE'" "warning"
        fi

        if jq -e '.github' "$CONFIG_FILE" > /dev/null 2>&1; then
            validate_check "GitHub 설정 존재" "jq -e '.github.user.username' '$CONFIG_FILE'" "warning"
        fi

        if jq -e '.output' "$CONFIG_FILE" > /dev/null 2>&1; then
            validate_check "회고록 경로 설정" "jq -e '.output.retrospectivePath' '$CONFIG_FILE'" "warning"
        fi
    fi
else
    print_warning "jq가 설치되지 않아 JSON 검증을 건너뜁니다."
    print_info "설치: sudo apt install jq (Linux) 또는 brew install jq (macOS)"
fi

echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 3: Environment Variables Check
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo "[3/5] 환경 변수 확인..."
echo ""

if [[ -f "$ENV_FILE" ]]; then
    # Load .env file
    source "$ENV_FILE"

    validate_check "ATLASSIAN_URL" "test -n '$ATLASSIAN_URL'" "warning"
    validate_check "ATLASSIAN_EMAIL" "test -n '$ATLASSIAN_EMAIL'" "warning"
    validate_check "ATLASSIAN_API_TOKEN" "test -n '$ATLASSIAN_API_TOKEN'" "warning"

    # Check token format (basic validation)
    if [[ -n "$ATLASSIAN_API_TOKEN" && ${#ATLASSIAN_API_TOKEN} -lt 10 ]]; then
        print_warning "ATLASSIAN_API_TOKEN이 너무 짧습니다. 올바른 토큰인지 확인하세요."
    fi
else
    print_info ".env 파일이 없습니다 (선택 사항)"
fi

echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 4: Git Configuration Check
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo "[4/5] Git 설정 확인..."
echo ""

GIT_USER_NAME=$(git config user.name 2>/dev/null || echo "")
GIT_USER_EMAIL=$(git config user.email 2>/dev/null || echo "")

if validate_check "git config user.name" "test -n '$GIT_USER_NAME'" "warning"; then
    print_info "  → $GIT_USER_NAME"
fi

if validate_check "git config user.email" "test -n '$GIT_USER_EMAIL'" "warning"; then
    print_info "  → $GIT_USER_EMAIL"
fi

# Check if gh CLI is installed
if command -v gh &> /dev/null; then
    validate_check "GitHub CLI (gh) 설치됨" "command -v gh" "warning"

    # Check gh auth status
    if gh auth status &> /dev/null; then
        print_success "GitHub CLI 인증 완료"
    else
        print_warning "GitHub CLI 인증 필요 (gh auth login)"
    fi
else
    print_info "GitHub CLI (gh)가 설치되지 않음 (선택 사항)"
fi

# Check if glab CLI is installed
if command -v glab &> /dev/null; then
    validate_check "GitLab CLI (glab) 설치됨" "command -v glab" "warning"
else
    print_info "GitLab CLI (glab)가 설치되지 않음 (선택 사항)"
fi

echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 5: Storage Path Check
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo "[5/5] 저장 경로 확인..."
echo ""

# Get retrospective path from config
RETRO_PATH="$RETRO_DIR"
if [[ -f "$CONFIG_FILE" ]] && command -v jq &> /dev/null; then
    RETRO_PATH=$(jq -r '.output.retrospectivePath // "~/.claude/retrospectives"' "$CONFIG_FILE")
    RETRO_PATH="${RETRO_PATH/#\~/$HOME}"
fi

validate_check "회고록 디렉토리 존재" "test -d '$RETRO_PATH'" "warning"

if [[ -d "$RETRO_PATH" ]]; then
    validate_check "회고록 디렉토리 쓰기 권한" "test -w '$RETRO_PATH'" "error"
    print_info "  → $RETRO_PATH"
fi

echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Summary
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

print_header "검증 결과"

echo "총 검사 항목: $TOTAL_CHECKS"
echo -e "${GREEN}통과: $PASSED_CHECKS${NC}"
echo -e "${YELLOW}경고: $WARNING_CHECKS${NC}"
echo -e "${RED}실패: $FAILED_CHECKS${NC}"
echo ""

if [[ $FAILED_CHECKS -eq 0 ]]; then
    print_success "모든 필수 검증 통과!"

    if [[ $WARNING_CHECKS -gt 0 ]]; then
        echo ""
        print_info "선택 사항 경고가 있습니다. 필요하면 설정을 완료하세요."
    fi

    echo ""
    print_success "Productivity Agents를 사용할 준비가 완료되었습니다!"
    exit 0
else
    echo ""
    print_error "필수 검증 실패"
    print_info "다음 명령어로 설정을 다시 실행하세요:"
    echo "  $(dirname "$0")/init.sh"
    exit 1
fi
