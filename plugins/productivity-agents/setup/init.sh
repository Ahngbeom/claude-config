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

read -p "계속하시겠습니까? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warning "설정을 취소했습니다."
    exit 0
fi

# Check for existing configuration
if [[ -f "$CONFIG_FILE" ]]; then
    print_warning "기존 설정 파일이 발견되었습니다: $CONFIG_FILE"
    echo ""
    read -p "기존 설정을 덮어쓰시겠습니까? (백업 생성됨) (y/N): " -n 1 -r
    echo
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

# Create productivity-agents.json
cat > "$CONFIG_FILE" <<EOF
{
  "\$schema": "https://raw.githubusercontent.com/Ahngbeom/claude-config/main/plugins/productivity-agents/.claude-plugin/settings-schema.json",
EOF

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

# Create .env file
cat > "$ENV_FILE" <<EOF
# Productivity Agents - Environment Variables
# Generated by setup/init.sh on $(date)

EOF

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

# Secure .env file
chmod 600 "$ENV_FILE"
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
