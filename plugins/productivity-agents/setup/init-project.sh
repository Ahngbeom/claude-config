#!/bin/bash

# Productivity Agents - Project Setup Script
# This script creates project-specific configuration for productivity agents

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

# Get current directory
PROJECT_DIR="$(pwd)"
PROJECT_NAME="$(basename "$PROJECT_DIR")"

# Configuration paths
CLAUDE_DIR="$PROJECT_DIR/.claude"
SETTINGS_FILE="$CLAUDE_DIR/settings.local.json"
GITIGNORE_FILE="$PROJECT_DIR/.gitignore"

# Welcome banner
clear
print_header "🚀 프로젝트별 Productivity Agents 설정"

echo "현재 디렉토리: $PROJECT_DIR"
echo "프로젝트 이름: $PROJECT_NAME"
echo ""

# Check if we're in a git repository
if [[ ! -d "$PROJECT_DIR/.git" ]]; then
    print_warning "Git 레포지토리가 감지되지 않았습니다."
    read -p "계속하시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "설정을 취소했습니다."
        exit 0
    fi
fi

# Initialize variables
REPO_TYPE=""
REPO_OWNER=""
REPO_NAME=""
REPO_URL=""
REPO_PATH=""
JIRA_PROJECT=""
RETRO_PATH="./docs/retrospectives"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 1: Auto-detect Git Repository
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

print_header "📦 Git 레포지토리 정보 자동 감지"

if [[ -d "$PROJECT_DIR/.git" ]]; then
    # Get remote URL
    REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")

    if [[ -n "$REMOTE_URL" ]]; then
        print_success "Remote URL 감지: $REMOTE_URL"

        # Detect repository type and parse information
        if [[ "$REMOTE_URL" =~ github\.com ]]; then
            REPO_TYPE="github"

            # Parse GitHub URL
            if [[ "$REMOTE_URL" =~ github\.com[:/]([^/]+)/([^/.]+) ]]; then
                REPO_OWNER="${BASH_REMATCH[1]}"
                REPO_NAME="${BASH_REMATCH[2]}"

                print_success "타입: GitHub"
                print_info "Owner: $REPO_OWNER"
                print_info "Repo: $REPO_NAME"
            fi
        elif [[ "$REMOTE_URL" =~ gitlab ]]; then
            REPO_TYPE="gitlab"

            # Parse GitLab URL
            if [[ "$REMOTE_URL" =~ gitlab\.com[:/](.+)\.git ]]; then
                REPO_PATH="${BASH_REMATCH[1]}"

                print_success "타입: GitLab"
                print_info "Path: $REPO_PATH"
            elif [[ "$REMOTE_URL" =~ ([^:/]+)[:/](.+)\.git ]]; then
                REPO_URL="${BASH_REMATCH[1]}"
                REPO_PATH="${BASH_REMATCH[2]}"

                print_success "타입: GitLab (self-hosted)"
                print_info "URL: $REPO_URL"
                print_info "Path: $REPO_PATH"
            fi
        else
            print_warning "알 수 없는 Git 호스트입니다. 수동으로 입력해주세요."
        fi
    else
        print_warning "Remote URL을 찾을 수 없습니다."
    fi
else
    print_info "Git 레포지토리가 아닙니다."
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 2: Manual Repository Configuration (if needed)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if [[ -z "$REPO_TYPE" ]]; then
    print_header "📝 레포지토리 정보 수동 입력"

    echo "레포지토리 타입 선택:"
    echo "  1) GitHub"
    echo "  2) GitLab"
    echo "  3) 건너뛰기"
    read -p "선택 (1-3): " -n 1 -r
    echo

    case $REPLY in
        1)
            REPO_TYPE="github"
            read -p "Owner: " REPO_OWNER
            read -p "Repo: " REPO_NAME
            ;;
        2)
            REPO_TYPE="gitlab"
            read -p "GitLab URL [gitlab.com]: " REPO_URL
            REPO_URL=${REPO_URL:-gitlab.com}
            read -p "Path (예: group/project): " REPO_PATH
            ;;
        *)
            print_info "레포지토리 설정을 건너뜁니다."
            ;;
    esac
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 3: Jira Project Configuration
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

print_header "📋 Jira 프로젝트 설정"

echo "Jira 프로젝트 키 (선택):"
echo "  예시: PROJ, DEV, INFRA"
read -p "프로젝트 키 (Enter=스킵): " JIRA_PROJECT

if [[ -n "$JIRA_PROJECT" ]]; then
    print_success "Jira 프로젝트: $JIRA_PROJECT"
else
    print_info "Jira 프로젝트 설정을 건너뜁니다."
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 4: Retrospective Path
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

print_header "📁 회고록 저장 경로"

echo "회고록을 저장할 경로:"
read -p "경로 [./docs/retrospectives]: " RETRO_PATH
RETRO_PATH=${RETRO_PATH:-./docs/retrospectives}

print_success "저장 경로: $RETRO_PATH"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Generate Configuration File
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

print_header "💾 설정 파일 생성 중"

# Create .claude directory
mkdir -p "$CLAUDE_DIR"

# Check for existing settings file
EXISTING_SETTINGS=""
if [[ -f "$SETTINGS_FILE" ]]; then
    print_warning "기존 설정 파일이 발견되었습니다."
    EXISTING_SETTINGS=$(cat "$SETTINGS_FILE")

    read -p "기존 설정과 병합하시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        EXISTING_SETTINGS=""
        BACKUP_FILE="$SETTINGS_FILE.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$SETTINGS_FILE" "$BACKUP_FILE"
        print_success "백업 생성됨: $BACKUP_FILE"
    fi
fi

# Create settings.local.json
if [[ -z "$EXISTING_SETTINGS" ]]; then
    # New file
    cat > "$SETTINGS_FILE" <<EOF
{
  "productivityAgents": {
EOF

    # Add Jira configuration
    if [[ -n "$JIRA_PROJECT" ]]; then
        cat >> "$SETTINGS_FILE" <<EOF
    "jira": {
      "project": "$JIRA_PROJECT",
      "defaultAssignee": "use-global"
    },
EOF
    fi

    # Add repositories configuration
    if [[ -n "$REPO_TYPE" ]]; then
        cat >> "$SETTINGS_FILE" <<EOF
    "repositories": [
EOF

        if [[ "$REPO_TYPE" == "github" ]]; then
            cat >> "$SETTINGS_FILE" <<EOF
      {
        "name": "main",
        "type": "github",
        "owner": "$REPO_OWNER",
        "repo": "$REPO_NAME",
        "branch": "main"
      }
EOF
        elif [[ "$REPO_TYPE" == "gitlab" ]]; then
            cat >> "$SETTINGS_FILE" <<EOF
      {
        "name": "main",
        "type": "gitlab",
        "url": "$REPO_URL",
        "path": "$REPO_PATH",
        "branch": "main"
      }
EOF
        fi

        cat >> "$SETTINGS_FILE" <<EOF
    ],
EOF
    fi

    # Add output configuration
    cat >> "$SETTINGS_FILE" <<EOF
    "output": {
      "retrospectivePath": "$RETRO_PATH"
    }
  }
}
EOF
else
    # Merge with existing settings
    print_info "기존 설정과 병합 기능은 추후 구현 예정입니다."
    print_info "지금은 수동으로 $SETTINGS_FILE을 편집해주세요."
fi

print_success "생성됨: $SETTINGS_FILE"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Update .gitignore
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

print_header "🔒 .gitignore 업데이트"

GITIGNORE_PATTERNS=(
    "# Productivity Agents - 민감 정보"
    ".env"
    ".env.local"
    ".claude/.env"
    ".credentials.json"
)

# Check if .gitignore exists
if [[ ! -f "$GITIGNORE_FILE" ]]; then
    touch "$GITIGNORE_FILE"
    print_info ".gitignore 파일 생성됨"
fi

# Add patterns if not already present
ADDED=0
for pattern in "${GITIGNORE_PATTERNS[@]}"; do
    if ! grep -qF "$pattern" "$GITIGNORE_FILE" 2>/dev/null; then
        echo "$pattern" >> "$GITIGNORE_FILE"
        ADDED=$((ADDED + 1))
    fi
done

if [[ $ADDED -gt 0 ]]; then
    print_success ".gitignore 업데이트됨 ($ADDED개 패턴 추가)"
else
    print_info ".gitignore 이미 최신 상태"
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Create retrospectives directory
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if [[ ! "$RETRO_PATH" =~ ^\~ ]]; then
    mkdir -p "$RETRO_PATH"
    print_success "생성됨: $RETRO_PATH/"
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Summary
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

print_header "✅ 프로젝트 설정 완료"

echo "생성된 파일:"
echo "  ✓ $SETTINGS_FILE"
echo "  ✓ .gitignore 업데이트"
if [[ ! "$RETRO_PATH" =~ ^\~ ]]; then
    echo "  ✓ $RETRO_PATH/"
fi
echo ""

echo "설정 미리보기:"
cat "$SETTINGS_FILE"
echo ""

print_info "이제 이 프로젝트에서 productivity agents를 사용할 수 있습니다."
echo ""

if [[ -n "$JIRA_PROJECT" ]]; then
    echo "  - \"$JIRA_PROJECT 프로젝트 회고록 작성해줘\" (jira-retrospective)"
fi
if [[ -n "$REPO_TYPE" ]]; then
    echo "  - \"이 레포지토리의 지난 주 커밋 분석해줘\" (commit-retrospective)"
fi
echo ""

print_success "프로젝트 설정이 완료되었습니다!"
