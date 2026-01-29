#!/bin/bash

# Productivity Agents - Global Setup Script
# This script collects user information and creates global configuration files

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
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Default timeout for read commands (in seconds)
# Set PRODUCTIVITY_AGENTS_TIMEOUT env var to override, or 0 to disable
READ_TIMEOUT="${PRODUCTIVITY_AGENTS_TIMEOUT:-300}"

# Wrapper for read with timeout support
# Usage: timed_read [-s] [-n N] prompt_var [default_value]
timed_read() {
    local silent=""
    local nchars=""
    local var_name=""
    local default_val=""
    local prompt_text=""

    # Parse options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -s) silent="-s"; shift ;;
            -n) nchars="-n $2"; shift 2 ;;
            -p) prompt_text="$2"; shift 2 ;;
            *) break ;;
        esac
    done

    var_name="$1"
    default_val="${2:-}"

    if [[ "$READ_TIMEOUT" -gt 0 ]]; then
        # Use timeout if configured
        if ! read -t "$READ_TIMEOUT" $silent $nchars -p "$prompt_text" "$var_name" 2>/dev/null; then
            if [[ -n "$default_val" ]]; then
                eval "$var_name=\"$default_val\""
                echo ""
                print_warning "입력 대기 시간 초과. 기본값 사용: $default_val"
            else
                echo ""
                print_error "입력 대기 시간 초과 (${READ_TIMEOUT}초)"
                print_info "CI/CD 환경에서는 PRODUCTIVITY_AGENTS_TIMEOUT=0 으로 설정하여 비대화형 모드를 사용하세요."
                exit 1
            fi
        fi
    else
        # Non-interactive mode: use default value
        if [[ -n "$default_val" ]]; then
            eval "$var_name=\"$default_val\""
            print_info "비대화형 모드: 기본값 사용 - $default_val"
        else
            print_error "비대화형 모드에서 필수 입력값이 없습니다."
            exit 1
        fi
    fi
}

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Configuration paths
CLAUDE_DIR="$HOME/.claude"
CONFIG_FILE="$CLAUDE_DIR/productivity-agents.json"
ENV_FILE="$CLAUDE_DIR/.env"
RETRO_DIR="$CLAUDE_DIR/retrospectives"

# Templates
TEMPLATE_DIR="$SCRIPT_DIR/templates"
CONFIG_TEMPLATE="$TEMPLATE_DIR/productivity-agents.json.template"
ENV_TEMPLATE="$TEMPLATE_DIR/.env.template"

# Welcome banner
clear
print_header "🚀 Productivity Agents 초기 설정"

echo "이 스크립트는 다음 정보를 수집합니다:"
echo "  1. Atlassian (Jira) 계정 정보"
echo "  2. GitHub 계정 정보"
echo "  3. GitLab 계정 정보 (선택)"
echo "  4. 회고록 저장 경로"
echo ""
echo "생성될 파일:"
echo "  - $CONFIG_FILE"
echo "  - $ENV_FILE"
echo "  - $RETRO_DIR/"
echo ""

# Check for CI/CD environment (non-interactive mode)
if [[ "$READ_TIMEOUT" -eq 0 ]]; then
    print_info "비대화형 모드로 실행 중 (PRODUCTIVITY_AGENTS_TIMEOUT=0)"
    print_info "모든 설정은 환경 변수에서 읽어옵니다."
fi

if [[ "$READ_TIMEOUT" -gt 0 ]]; then
    read -t "$READ_TIMEOUT" -p "계속하시겠습니까? (y/N): " -n 1 -r REPLY || REPLY="n"
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "설정을 취소했습니다."
        exit 0
    fi
fi

# Check for existing configuration
if [[ -f "$CONFIG_FILE" ]]; then
    print_warning "기존 설정 파일이 발견되었습니다: $CONFIG_FILE"
    echo ""
    if [[ "$READ_TIMEOUT" -gt 0 ]]; then
        read -t "$READ_TIMEOUT" -p "기존 설정을 덮어쓰시겠습니까? (백업 생성됨) (y/N): " -n 1 -r REPLY || REPLY="y"
        echo
    else
        REPLY="y"
        print_info "비대화형 모드: 자동으로 백업 후 덮어씁니다."
    fi
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        BACKUP_FILE="$CONFIG_FILE.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$CONFIG_FILE" "$BACKUP_FILE"
        print_success "백업 생성됨: $BACKUP_FILE"
    else
        print_warning "설정을 취소했습니다."
        exit 0
    fi
fi

# Create ~/.claude directory if it doesn't exist
mkdir -p "$CLAUDE_DIR"

# Initialize variables
ATLASSIAN_URL=""
ATLASSIAN_EMAIL=""
ATLASSIAN_API_TOKEN=""
ATLASSIAN_ACCOUNT_ID=""
ATLASSIAN_DISPLAY_NAME=""

GITHUB_USERNAME=""
GITHUB_EMAIL=""
GITHUB_TOKEN=""

GITLAB_URL="gitlab.com"
GITLAB_USERNAME=""
GITLAB_EMAIL=""
GITLAB_TOKEN=""

RETRO_PATH="$RETRO_DIR"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 1: Atlassian (Jira) Configuration
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

print_header "📋 Atlassian (Jira) 설정"

read -p "Jira 회고록 기능을 사용하시겠습니까? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "1. Jira Cloud URL 입력:"
    echo "   예시: yourcompany.atlassian.net"
    read -p "   URL: " ATLASSIAN_URL

    echo ""
    echo "2. 사용자 이메일:"
    echo "   예시: user@company.com"
    read -p "   Email: " ATLASSIAN_EMAIL

    echo ""
    echo "3. API 토큰 생성:"
    echo "   https://id.atlassian.com/manage-profile/security/api-tokens"
    echo "   에서 API 토큰을 생성하세요."
    echo ""
    read -sp "   API Token: " ATLASSIAN_API_TOKEN
    echo ""

    # Validate inputs
    if [[ -z "$ATLASSIAN_URL" || -z "$ATLASSIAN_EMAIL" || -z "$ATLASSIAN_API_TOKEN" ]]; then
        print_error "필수 정보가 누락되었습니다. Atlassian 설정을 건너뜁니다."
        ATLASSIAN_URL=""
    else
        # Try to get Account ID (mock for now - in real scenario, would use MCP tools)
        print_info "Account ID를 설정에서 수동으로 입력하거나, 나중에 MCP 도구로 자동 조회할 수 있습니다."
        read -p "   Account ID (Enter=나중에 자동 조회): " ATLASSIAN_ACCOUNT_ID

        if [[ -z "$ATLASSIAN_ACCOUNT_ID" ]]; then
            ATLASSIAN_ACCOUNT_ID="AUTO_DETECT_VIA_MCP"
        fi

        read -p "   Display Name (선택): " ATLASSIAN_DISPLAY_NAME

        if [[ -z "$ATLASSIAN_DISPLAY_NAME" ]]; then
            ATLASSIAN_DISPLAY_NAME="$ATLASSIAN_EMAIL"
        fi

        print_success "Atlassian 설정 완료"
    fi
else
    print_info "Jira 설정을 건너뜁니다."
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 2: GitHub Configuration
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

print_header "🐙 GitHub 설정"

read -p "GitHub를 사용하시나요? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "1. GitHub 사용자명:"
    read -p "   Username: " GITHUB_USERNAME

    echo ""
    echo "2. GitHub 이메일:"
    read -p "   Email: " GITHUB_EMAIL

    echo ""
    echo "3. GitHub Personal Access Token (선택):"
    echo "   https://github.com/settings/tokens"
    echo "   (gh CLI가 설치되어 있으면 자동으로 사용됩니다)"
    read -sp "   Token (선택, Enter=건너뛰기): " GITHUB_TOKEN
    echo ""

    if [[ -z "$GITHUB_USERNAME" || -z "$GITHUB_EMAIL" ]]; then
        print_error "필수 정보가 누락되었습니다. GitHub 설정을 건너뜁니다."
        GITHUB_USERNAME=""
    else
        print_success "GitHub 설정 완료"
    fi
else
    print_info "GitHub 설정을 건너뜁니다."
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 3: GitLab Configuration
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

print_header "🦊 GitLab 설정"

read -p "GitLab를 사용하시나요? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "1. GitLab URL:"
    echo "   예시: gitlab.com 또는 gitlab.yourcompany.com"
    read -p "   URL [gitlab.com]: " GITLAB_URL
    GITLAB_URL=${GITLAB_URL:-gitlab.com}

    echo ""
    echo "2. 사용자명:"
    read -p "   Username: " GITLAB_USERNAME

    echo ""
    echo "3. 이메일:"
    read -p "   Email: " GITLAB_EMAIL

    echo ""
    echo "4. Personal Access Token (선택):"
    read -sp "   Token (선택, Enter=건너뛰기): " GITLAB_TOKEN
    echo ""

    if [[ -z "$GITLAB_USERNAME" || -z "$GITLAB_EMAIL" ]]; then
        print_error "필수 정보가 누락되었습니다. GitLab 설정을 건너뜁니다."
        GITLAB_USERNAME=""
    else
        print_success "GitLab 설정 완료"
    fi
else
    print_info "GitLab 설정을 건너뜁니다."
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 4: Output Configuration
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

print_header "📁 회고록 저장 경로 설정"

echo "회고록을 저장할 기본 경로:"
read -p "경로 [$RETRO_DIR]: " RETRO_PATH
RETRO_PATH=${RETRO_PATH:-$RETRO_DIR}

# Expand tilde
RETRO_PATH="${RETRO_PATH/#\~/$HOME}"

print_success "저장 경로 설정 완료"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Generate Configuration Files
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

print_header "💾 설정 파일 생성 중"

# Helper function to safely write to file
safe_write() {
    local file="$1"
    local content="$2"
    local mode="${3:-append}"  # 'create' or 'append'

    if [[ "$mode" == "create" ]]; then
        if ! echo "$content" > "$file" 2>&1; then
            print_error "파일 쓰기 실패: $file"
            print_error "디스크 공간이 부족하거나 권한이 없을 수 있습니다."
            exit 1
        fi
    else
        if ! echo "$content" >> "$file" 2>&1; then
            print_error "파일 추가 쓰기 실패: $file"
            print_error "디스크 공간이 부족하거나 권한이 없을 수 있습니다."
            exit 1
        fi
    fi
}

# Create productivity-agents.json with error handling
CONFIG_CONTENT='{'$'\n''  "$schema": "https://raw.githubusercontent.com/Ahngbeom/claude-config/main/plugins/productivity-agents/.claude-plugin/settings-schema.json",'

if ! cat > "$CONFIG_FILE" <<EOF
{
  "\$schema": "https://raw.githubusercontent.com/Ahngbeom/claude-config/main/plugins/productivity-agents/.claude-plugin/settings-schema.json",
EOF
then
    print_error "설정 파일 생성 실패: $CONFIG_FILE"
    print_error "디스크 공간이 부족하거나 쓰기 권한이 없을 수 있습니다."
    exit 1
fi

# Add Atlassian configuration
if [[ -n "$ATLASSIAN_URL" ]]; then
    cat >> "$CONFIG_FILE" <<EOF
  "atlassian": {
    "defaultUrl": "$ATLASSIAN_URL",
    "user": {
      "accountId": "$ATLASSIAN_ACCOUNT_ID",
      "email": "$ATLASSIAN_EMAIL",
      "displayName": "$ATLASSIAN_DISPLAY_NAME"
    }
  },
EOF
fi

# Add GitHub configuration
if [[ -n "$GITHUB_USERNAME" ]]; then
    cat >> "$CONFIG_FILE" <<EOF
  "github": {
    "defaultUrl": "github.com",
    "user": {
      "username": "$GITHUB_USERNAME",
      "email": "$GITHUB_EMAIL"
    }
  },
EOF
fi

# Add GitLab configuration
if [[ -n "$GITLAB_USERNAME" ]]; then
    cat >> "$CONFIG_FILE" <<EOF
  "gitlab": {
    "defaultUrl": "$GITLAB_URL",
    "user": {
      "username": "$GITLAB_USERNAME",
      "email": "$GITLAB_EMAIL"
    }
  },
EOF
fi

# Add output configuration
cat >> "$CONFIG_FILE" <<EOF
  "output": {
    "retrospectivePath": "$RETRO_PATH"
  }
}
EOF

print_success "생성됨: $CONFIG_FILE"

# Create .env file with error handling
if ! cat > "$ENV_FILE" <<EOF
# Productivity Agents - Environment Variables
# Generated by setup/init.sh on $(date)

EOF
then
    print_error ".env 파일 생성 실패: $ENV_FILE"
    print_error "디스크 공간이 부족하거나 쓰기 권한이 없을 수 있습니다."
    exit 1
fi

if [[ -n "$ATLASSIAN_URL" ]]; then
    cat >> "$ENV_FILE" <<EOF
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Atlassian (Jira) Configuration
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ATLASSIAN_URL=$ATLASSIAN_URL
ATLASSIAN_EMAIL=$ATLASSIAN_EMAIL
ATLASSIAN_API_TOKEN=$ATLASSIAN_API_TOKEN

EOF
fi

if [[ -n "$GITHUB_TOKEN" ]]; then
    cat >> "$ENV_FILE" <<EOF
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# GitHub Configuration
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

GITHUB_TOKEN=$GITHUB_TOKEN

EOF
fi

if [[ -n "$GITLAB_TOKEN" ]]; then
    cat >> "$ENV_FILE" <<EOF
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# GitLab Configuration
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

GITLAB_URL=$GITLAB_URL
GITLAB_TOKEN=$GITLAB_TOKEN

EOF
fi

# Secure .env file - CRITICAL: Must succeed to protect API tokens
if ! chmod 600 "$ENV_FILE" 2>&1; then
    print_error "보안 경고: $ENV_FILE 권한 설정 실패"
    print_error "API 토큰이 다른 사용자에게 노출될 수 있습니다!"
    print_error "파일 시스템이 UNIX 권한을 지원하는지 확인하세요. (FAT32/exFAT는 지원하지 않음)"
    exit 1
fi

# Verify permissions were actually set
ACTUAL_PERMS=$(stat -f "%Lp" "$ENV_FILE" 2>/dev/null || stat -c "%a" "$ENV_FILE" 2>/dev/null || echo "unknown")
if [[ "$ACTUAL_PERMS" != "600" && "$ACTUAL_PERMS" != "unknown" ]]; then
    print_error "보안 경고: $ENV_FILE 권한이 600으로 설정되지 않았습니다 (현재: $ACTUAL_PERMS)"
    print_error "API 토큰이 다른 사용자에게 노출될 수 있습니다!"
    exit 1
fi

print_success "생성됨: $ENV_FILE (권한: 600)"

# Create retrospectives directory
mkdir -p "$RETRO_PATH"
print_success "생성됨: $RETRO_PATH/"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Summary
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

print_header "✅ 설정 완료"

echo "다음 파일이 생성되었습니다:"
echo "  ✓ $CONFIG_FILE"
echo "  ✓ $ENV_FILE"
echo "  ✓ $RETRO_PATH/"
echo ""

if [[ -n "$ATLASSIAN_URL" && "$ATLASSIAN_ACCOUNT_ID" == "AUTO_DETECT_VIA_MCP" ]]; then
    print_warning "Atlassian Account ID는 나중에 MCP 도구로 자동 조회됩니다."
    echo ""
fi

echo "다음 명령어로 에이전트를 사용할 수 있습니다:"
if [[ -n "$ATLASSIAN_URL" ]]; then
    echo "  - \"지난 주 회고록 작성해줘\" (jira-retrospective)"
fi
if [[ -n "$GITHUB_USERNAME" || -n "$GITLAB_USERNAME" ]]; then
    echo "  - \"이번 주 내 커밋 회고록 작성해줘\" (commit-retrospective)"
fi
echo ""

print_info "프로젝트별 설정이 필요한 경우:"
echo "  cd /your/project"
echo "  $PLUGIN_DIR/setup/init-project.sh"
echo ""

print_success "초기 설정이 완료되었습니다!"
