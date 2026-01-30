#!/bin/bash

# Productivity Agents - Project Setup Script
# This script creates project-specific configuration for productivity agents
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Claude Code CLI 비대화형 모드 (Non-Interactive Mode)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Claude Code의 Bash 도구는 대화형 입력(read -p)을 지원하지 않습니다.
# 비대화형 모드에서는 환경변수로 값을 전달하세요:
#
#   PRODUCTIVITY_AGENTS_TIMEOUT=0 \
#   JIRA_PROJECT="PROJ" \
#   REPO_TYPE="github" \
#   REPO_OWNER="username" \
#   REPO_NAME="repository" \
#   RETRO_PATH="./docs/retrospectives" \
#   ./init-project.sh
#
# 환경변수 목록:
#   PRODUCTIVITY_AGENTS_TIMEOUT - 입력 대기 시간(초), 0=비대화형 모드
#   JIRA_PROJECT    - Jira 프로젝트 키 (예: PROJ, DEV)
#   REPO_TYPE       - 레포지토리 타입 (github, gitlab)
#   REPO_OWNER      - GitHub owner (REPO_TYPE=github일 때)
#   REPO_NAME       - GitHub repo 이름 (REPO_TYPE=github일 때)
#   REPO_URL        - GitLab URL (REPO_TYPE=gitlab일 때, 기본: gitlab.com)
#   REPO_PATH       - GitLab 프로젝트 경로 (REPO_TYPE=gitlab일 때)
#   RETRO_PATH      - 회고록 저장 경로 (기본: ./docs/retrospectives)
#   MERGE_EXISTING  - 기존 설정 병합 여부 (y/n)
#   SKIP_GIT_CHECK  - Git 레포지토리 검사 건너뛰기 (y/n)
#   REPO_BRANCH     - 현재 저장소의 기본 브랜치 (기본: main)
#   REPOSITORIES    - 전체 저장소 JSON 배열 (예: '[{"name":"main","type":"github","owner":"co","repo":"proj","branch":"main"}]')
#   USE_GLOBAL_REPOS - 글로벌 설정에서 가져올 저장소 별칭 목록 (쉼표 구분, 예: "api,infra")
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

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

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Non-Interactive Mode Configuration
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Default timeout for read commands (in seconds)
# Set to 0 for non-interactive mode (CI/CD or Claude Code)
READ_TIMEOUT="${PRODUCTIVITY_AGENTS_TIMEOUT:-300}"

# Environment variables for non-interactive mode defaults
ENV_JIRA_PROJECT="${JIRA_PROJECT:-}"
ENV_REPO_TYPE="${REPO_TYPE:-}"
ENV_REPO_OWNER="${REPO_OWNER:-}"
ENV_REPO_NAME="${REPO_NAME:-}"
ENV_REPO_URL="${REPO_URL:-}"
ENV_REPO_PATH="${REPO_PATH:-}"
ENV_RETRO_PATH="${RETRO_PATH:-./docs/retrospectives}"
ENV_MERGE_EXISTING="${MERGE_EXISTING:-}"
ENV_SKIP_GIT_CHECK="${SKIP_GIT_CHECK:-}"
ENV_REPO_BRANCH="${REPO_BRANCH:-main}"
ENV_REPOSITORIES="${REPOSITORIES:-}"
ENV_USE_GLOBAL_REPOS="${USE_GLOBAL_REPOS:-}"

# Helper function for read with timeout and default value
# Usage: read_with_default "prompt" "default_value" "variable_name"
read_with_default() {
    local prompt="$1"
    local default="$2"
    local varname="$3"
    local value=""

    if [[ "$READ_TIMEOUT" -eq 0 ]]; then
        # Non-interactive mode: use default value immediately
        value="$default"
        if [[ -n "$value" ]]; then
            print_info "비대화형 모드: $varname=$value"
        fi
    else
        # Interactive mode: prompt user with timeout
        if read -t "$READ_TIMEOUT" -p "$prompt" value; then
            : # Read succeeded
        else
            # Timeout or EOF: use default
            echo ""
            if [[ -n "$default" ]]; then
                print_info "타임아웃: 기본값 사용 ($default)"
            fi
            value="$default"
        fi
    fi

    # Set the variable in the calling scope
    eval "$varname=\"\$value\""
}

# Helper function for single character read with timeout
# Usage: read_char_with_default "prompt" "default_char" "variable_name"
read_char_with_default() {
    local prompt="$1"
    local default="$2"
    local varname="$3"
    local value=""

    if [[ "$READ_TIMEOUT" -eq 0 ]]; then
        # Non-interactive mode: use default value immediately
        value="$default"
        if [[ -n "$value" ]]; then
            print_info "비대화형 모드: $varname=$value"
        fi
    else
        # Interactive mode: prompt user with timeout
        if read -t "$READ_TIMEOUT" -p "$prompt" -n 1 -r value; then
            echo ""
        else
            # Timeout or EOF: use default
            echo ""
            if [[ -n "$default" ]]; then
                print_info "타임아웃: 기본값 사용 ($default)"
            fi
            value="$default"
        fi
    fi

    # Set the variable in the calling scope
    eval "$varname=\"\$value\""
}

# Check for non-interactive mode at start
if [[ "$READ_TIMEOUT" -eq 0 ]]; then
    print_info "비대화형 모드로 실행 중 (PRODUCTIVITY_AGENTS_TIMEOUT=0)"
    print_info "환경변수에서 설정값을 읽습니다."
fi

# Get current directory
PROJECT_DIR="$(pwd)"
PROJECT_NAME="$(basename "$PROJECT_DIR")"

# Configuration paths
CLAUDE_DIR="$PROJECT_DIR/.claude"
SETTINGS_FILE="$CLAUDE_DIR/settings.local.json"
GITIGNORE_FILE="$PROJECT_DIR/.gitignore"

# Global configuration (for reading default repositories)
GLOBAL_CONFIG_FILE="$HOME/.claude/productivity-agents.json"

# Repositories array (will be populated during setup)
REPOSITORIES_JSON="[]"

# Welcome banner
clear
print_header "🚀 프로젝트별 Productivity Agents 설정"

echo "현재 디렉토리: $PROJECT_DIR"
echo "프로젝트 이름: $PROJECT_NAME"
echo ""

# Check if we're in a git repository
if [[ ! -d "$PROJECT_DIR/.git" ]]; then
    print_warning "Git 레포지토리가 감지되지 않았습니다."

    if [[ "$ENV_SKIP_GIT_CHECK" =~ ^[Yy]$ ]]; then
        print_info "비대화형 모드: Git 체크 건너뛰기"
    else
        read_char_with_default "계속하시겠습니까? (y/N): " "n" "REPLY"
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_warning "설정을 취소했습니다."
            exit 0
        fi
    fi
fi

# Initialize variables from environment or defaults
REPO_TYPE="$ENV_REPO_TYPE"
REPO_OWNER="$ENV_REPO_OWNER"
REPO_NAME="$ENV_REPO_NAME"
REPO_URL="$ENV_REPO_URL"
REPO_PATH="$ENV_REPO_PATH"
JIRA_PROJECT="$ENV_JIRA_PROJECT"
RETRO_PATH="$ENV_RETRO_PATH"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 1: Auto-detect Git Repository
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

print_header "📦 Git 레포지토리 정보 자동 감지"

if [[ -d "$PROJECT_DIR/.git" ]]; then
    # Get remote URL with proper error handling
    REMOTE_URL=""
    GIT_ERROR=""
    if ! GIT_ERROR=$(git remote get-url origin 2>&1); then
        # Handle specific git errors
        if [[ "$GIT_ERROR" == *"No such remote"* ]]; then
            print_info "Remote 'origin'이 설정되지 않았습니다."
        elif [[ "$GIT_ERROR" == *"not a git repository"* ]]; then
            print_warning "유효한 Git 레포지토리가 아닙니다."
        else
            print_warning "Remote URL 조회 실패: $GIT_ERROR"
        fi
    else
        REMOTE_URL="$GIT_ERROR"  # On success, output goes to GIT_ERROR variable
    fi

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

            # Parse GitLab URL - handle various formats:
            # - git@gitlab.com:group/project.git
            # - https://gitlab.com/group/project.git
            # - git@gitlab.mycompany.com:group/subgroup/project.git
            # - https://gitlab.mycompany.com/group/project.git

            # Remove .git suffix for unified parsing
            REMOTE_URL_CLEAN="${REMOTE_URL%.git}"

            # Extract host and path from SSH format (git@host:path)
            if [[ "$REMOTE_URL_CLEAN" =~ ^git@([^:]+):(.+)$ ]]; then
                GITLAB_HOST="${BASH_REMATCH[1]}"
                REPO_PATH="${BASH_REMATCH[2]}"
            # Extract host and path from HTTPS format (https://host/path)
            elif [[ "$REMOTE_URL_CLEAN" =~ ^https?://([^/]+)/(.+)$ ]]; then
                GITLAB_HOST="${BASH_REMATCH[1]}"
                REPO_PATH="${BASH_REMATCH[2]}"
            else
                print_warning "GitLab URL 파싱 실패. 수동으로 입력해주세요."
                REPO_TYPE=""
            fi

            # Print parsed information if successful
            if [[ -n "$REPO_PATH" && -n "$GITLAB_HOST" ]]; then
                if [[ "$GITLAB_HOST" == "gitlab.com" ]]; then
                    print_success "타입: GitLab"
                else
                    REPO_URL="$GITLAB_HOST"
                    print_success "타입: GitLab (self-hosted)"
                    print_info "URL: $REPO_URL"
                fi
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
# Helper: Add repository to JSON array
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Helper function to add a GitHub repo to REPOSITORIES_JSON
add_github_repo() {
    local name="$1"
    local owner="$2"
    local repo="$3"
    local branch="${4:-main}"

    if command -v jq &> /dev/null; then
        REPOSITORIES_JSON=$(echo "$REPOSITORIES_JSON" | jq --arg name "$name" --arg owner "$owner" --arg repo "$repo" --arg branch "$branch" \
            '. + [{"name": $name, "type": "github", "owner": $owner, "repo": $repo, "branch": $branch}]')
    else
        local new_entry="{\"name\":\"$name\",\"type\":\"github\",\"owner\":\"$owner\",\"repo\":\"$repo\",\"branch\":\"$branch\"}"
        if [[ "$REPOSITORIES_JSON" == "[]" || -z "$REPOSITORIES_JSON" ]]; then
            REPOSITORIES_JSON="[$new_entry]"
        elif [[ "$REPOSITORIES_JSON" =~ ^\[.*\]$ ]]; then
            REPOSITORIES_JSON="${REPOSITORIES_JSON%]},$new_entry]"
        else
            print_error "잘못된 JSON 배열 형식"
            return 1
        fi
    fi
}

# Helper function to add a GitLab repo to REPOSITORIES_JSON
add_gitlab_repo() {
    local name="$1"
    local url="$2"
    local path="$3"
    local branch="${4:-main}"

    if command -v jq &> /dev/null; then
        REPOSITORIES_JSON=$(echo "$REPOSITORIES_JSON" | jq --arg name "$name" --arg url "$url" --arg path "$path" --arg branch "$branch" \
            '. + [{"name": $name, "type": "gitlab", "url": $url, "path": $path, "branch": $branch}]')
    else
        local new_entry="{\"name\":\"$name\",\"type\":\"gitlab\",\"url\":\"$url\",\"path\":\"$path\",\"branch\":\"$branch\"}"
        if [[ "$REPOSITORIES_JSON" == "[]" || -z "$REPOSITORIES_JSON" ]]; then
            REPOSITORIES_JSON="[$new_entry]"
        elif [[ "$REPOSITORIES_JSON" =~ ^\[.*\]$ ]]; then
            REPOSITORIES_JSON="${REPOSITORIES_JSON%]},$new_entry]"
        else
            print_error "잘못된 JSON 배열 형식"
            return 1
        fi
    fi
}

# Helper function to display current repositories
display_repositories() {
    echo ""
    echo "현재 저장소 목록:"
    if [[ "$REPOSITORIES_JSON" == "[]" ]]; then
        echo "  (없음)"
    else
        if command -v jq &> /dev/null; then
            echo "$REPOSITORIES_JSON" | jq -r '.[] | "  \(.name): \(.type):\(if .type == "github" then "\(.owner)/\(.repo)" else "\(.url)/\(.path)" end)@\(.branch)"'
        else
            echo "  $REPOSITORIES_JSON"
        fi
    fi
    echo ""
}

# Helper function to load global default repositories
load_global_repos() {
    local repo_type="$1"  # "github" or "gitlab"

    if [[ ! -f "$GLOBAL_CONFIG_FILE" ]]; then
        print_warning "글로벌 설정 파일이 없습니다: $GLOBAL_CONFIG_FILE"
        return 1
    fi

    if ! command -v jq &> /dev/null; then
        print_warning "jq가 설치되지 않아 글로벌 저장소를 로드할 수 없습니다."
        return 1
    fi

    local repos
    repos=$(jq -r ".$repo_type.defaultRepositories // []" "$GLOBAL_CONFIG_FILE" 2>/dev/null)

    if [[ "$repos" == "[]" || -z "$repos" ]]; then
        print_info "$repo_type 글로벌 기본 저장소가 없습니다."
        return 1
    fi

    echo "$repos"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 2: Repository Configuration (Auto-detect + Manual)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# First, add auto-detected repository to the list
if [[ -n "$REPO_TYPE" ]]; then
    if [[ "$REPO_TYPE" == "github" && -n "$REPO_OWNER" && -n "$REPO_NAME" ]]; then
        add_github_repo "main" "$REPO_OWNER" "$REPO_NAME" "$ENV_REPO_BRANCH"
    elif [[ "$REPO_TYPE" == "gitlab" && -n "$REPO_PATH" ]]; then
        add_gitlab_repo "main" "${REPO_URL:-gitlab.com}" "$REPO_PATH" "$ENV_REPO_BRANCH"
    fi
fi

# Non-interactive mode: handle REPOSITORIES environment variable
if [[ "$READ_TIMEOUT" -eq 0 ]]; then
    if [[ -n "$ENV_REPOSITORIES" ]]; then
        print_info "비대화형 모드: REPOSITORIES 환경변수에서 저장소 로드"
        REPOSITORIES_JSON="$ENV_REPOSITORIES"
    elif [[ -n "$ENV_USE_GLOBAL_REPOS" ]]; then
        print_info "비대화형 모드: USE_GLOBAL_REPOS=$ENV_USE_GLOBAL_REPOS"
        # Load specified global repos by alias
        IFS=',' read -ra ALIASES <<< "$ENV_USE_GLOBAL_REPOS"
        for alias in "${ALIASES[@]}"; do
            alias=$(echo "$alias" | tr -d ' ')
            [[ -z "$alias" ]] && continue  # 빈 별칭 건너뛰기

            # Try GitHub first
            if command -v jq &> /dev/null && [[ -f "$GLOBAL_CONFIG_FILE" ]]; then
                github_repo=$(jq -r ".github.defaultRepositories[]? | select(.alias == \"$alias\")" "$GLOBAL_CONFIG_FILE" 2>/dev/null)
                if [[ -n "$github_repo" ]]; then
                    owner=$(echo "$github_repo" | jq -r '.owner')
                    repo=$(echo "$github_repo" | jq -r '.repo')
                    branch=$(echo "$github_repo" | jq -r '.branch // "main"')
                    add_github_repo "$alias" "$owner" "$repo" "$branch"
                    print_info "글로벌 저장소 로드: $alias (github)"
                    continue
                fi

                # Try GitLab
                gitlab_repo=$(jq -r ".gitlab.defaultRepositories[]? | select(.alias == \"$alias\")" "$GLOBAL_CONFIG_FILE" 2>/dev/null)
                if [[ -n "$gitlab_repo" ]]; then
                    url=$(echo "$gitlab_repo" | jq -r '.url // "gitlab.com"')
                    path=$(echo "$gitlab_repo" | jq -r '.path')
                    branch=$(echo "$gitlab_repo" | jq -r '.branch // "main"')
                    add_gitlab_repo "$alias" "$url" "$path" "$branch"
                    print_info "글로벌 저장소 로드: $alias (gitlab)"
                    continue
                fi

                print_warning "글로벌 저장소를 찾을 수 없음: $alias"
            fi
        done
    fi
else
    # Interactive mode: Repository management menu
    print_header "📦 추가 저장소 설정"

    display_repositories

    while true; do
        echo "추가 저장소를 등록하시겠습니까?"
        echo "  [1] 글로벌 기본 저장소에서 선택"
        echo "  [2] 새 GitHub 저장소 추가"
        echo "  [3] 새 GitLab 저장소 추가"
        echo "  [4] 저장소 삭제"
        echo "  [5] 브랜치 변경"
        echo "  [6] 완료"
        read_char_with_default "선택 (1-6): " "6" "MENU_CHOICE"

        case $MENU_CHOICE in
            1)
                # Select from global default repositories
                echo ""
                echo "글로벌 기본 저장소:"

                GITHUB_GLOBAL_REPOS=$(load_global_repos "github" 2>/dev/null || echo "[]")
                GITLAB_GLOBAL_REPOS=$(load_global_repos "gitlab" 2>/dev/null || echo "[]")

                if [[ "$GITHUB_GLOBAL_REPOS" == "[]" && "$GITLAB_GLOBAL_REPOS" == "[]" ]]; then
                    print_warning "등록된 글로벌 기본 저장소가 없습니다."
                    print_info "init.sh를 다시 실행하여 기본 저장소를 등록하세요."
                    continue
                fi

                # List GitHub repos
                if [[ "$GITHUB_GLOBAL_REPOS" != "[]" ]]; then
                    echo "  GitHub:"
                    echo "$GITHUB_GLOBAL_REPOS" | jq -r '.[] | "    - \(.alias): \(.owner)/\(.repo)"'
                fi

                # List GitLab repos
                if [[ "$GITLAB_GLOBAL_REPOS" != "[]" ]]; then
                    echo "  GitLab:"
                    echo "$GITLAB_GLOBAL_REPOS" | jq -r '.[] | "    - \(.alias): \(.url)/\(.path)"'
                fi

                echo ""
                read_with_default "추가할 저장소 별칭 (쉼표 구분): " "" "SELECTED_ALIASES"

                if [[ -n "$SELECTED_ALIASES" ]]; then
                    IFS=',' read -ra ALIASES <<< "$SELECTED_ALIASES"
                    for alias in "${ALIASES[@]}"; do
                        alias=$(echo "$alias" | tr -d ' ')
                        [[ -z "$alias" ]] && continue  # 빈 별칭 건너뛰기

                        # Try GitHub
                        github_repo=$(echo "$GITHUB_GLOBAL_REPOS" | jq -r ".[] | select(.alias == \"$alias\")" 2>/dev/null)
                        if [[ -n "$github_repo" ]]; then
                            owner=$(echo "$github_repo" | jq -r '.owner')
                            repo=$(echo "$github_repo" | jq -r '.repo')
                            branch=$(echo "$github_repo" | jq -r '.branch // "main"')
                            add_github_repo "$alias" "$owner" "$repo" "$branch"
                            print_success "추가됨: $alias (github:$owner/$repo)"
                            continue
                        fi

                        # Try GitLab
                        gitlab_repo=$(echo "$GITLAB_GLOBAL_REPOS" | jq -r ".[] | select(.alias == \"$alias\")" 2>/dev/null)
                        if [[ -n "$gitlab_repo" ]]; then
                            url=$(echo "$gitlab_repo" | jq -r '.url // "gitlab.com"')
                            path=$(echo "$gitlab_repo" | jq -r '.path')
                            branch=$(echo "$gitlab_repo" | jq -r '.branch // "main"')
                            add_gitlab_repo "$alias" "$url" "$path" "$branch"
                            print_success "추가됨: $alias (gitlab:$url/$path)"
                            continue
                        fi

                        print_warning "저장소를 찾을 수 없음: $alias"
                    done
                fi

                display_repositories
                ;;

            2)
                # Add new GitHub repository
                echo ""
                read_with_default "저장소 이름 (프로젝트 내 식별자): " "" "NEW_NAME"
                read_with_default "Owner: " "" "NEW_OWNER"
                read_with_default "Repo: " "" "NEW_REPO"
                read_with_default "브랜치 [main]: " "main" "NEW_BRANCH"

                if [[ -n "$NEW_NAME" && -n "$NEW_OWNER" && -n "$NEW_REPO" ]]; then
                    add_github_repo "$NEW_NAME" "$NEW_OWNER" "$NEW_REPO" "$NEW_BRANCH"
                    print_success "추가됨: $NEW_NAME (github:$NEW_OWNER/$NEW_REPO@$NEW_BRANCH)"
                else
                    print_warning "필수 정보가 누락되었습니다."
                fi

                display_repositories
                ;;

            3)
                # Add new GitLab repository
                echo ""
                read_with_default "저장소 이름 (프로젝트 내 식별자): " "" "NEW_NAME"
                read_with_default "GitLab URL [gitlab.com]: " "gitlab.com" "NEW_URL"
                read_with_default "Path (예: group/project): " "" "NEW_PATH"
                read_with_default "브랜치 [main]: " "main" "NEW_BRANCH"

                if [[ -n "$NEW_NAME" && -n "$NEW_PATH" ]]; then
                    add_gitlab_repo "$NEW_NAME" "$NEW_URL" "$NEW_PATH" "$NEW_BRANCH"
                    print_success "추가됨: $NEW_NAME (gitlab:$NEW_URL/$NEW_PATH@$NEW_BRANCH)"
                else
                    print_warning "필수 정보가 누락되었습니다."
                fi

                display_repositories
                ;;

            4)
                # Delete repository
                if [[ "$REPOSITORIES_JSON" == "[]" ]]; then
                    print_warning "삭제할 저장소가 없습니다."
                    continue
                fi

                display_repositories
                read_with_default "삭제할 저장소 이름: " "" "DEL_NAME"

                if [[ -n "$DEL_NAME" ]] && command -v jq &> /dev/null; then
                    REPOSITORIES_JSON=$(echo "$REPOSITORIES_JSON" | jq --arg name "$DEL_NAME" '[.[] | select(.name != $name)]')
                    print_success "삭제됨: $DEL_NAME"
                else
                    print_warning "jq가 필요하거나 이름이 입력되지 않았습니다."
                fi

                display_repositories
                ;;

            5)
                # Change branch
                if [[ "$REPOSITORIES_JSON" == "[]" ]]; then
                    print_warning "변경할 저장소가 없습니다."
                    continue
                fi

                display_repositories
                read_with_default "브랜치를 변경할 저장소 이름: " "" "TARGET_NAME"
                read_with_default "새 브랜치: " "" "NEW_BRANCH"

                if [[ -n "$TARGET_NAME" && -n "$NEW_BRANCH" ]] && command -v jq &> /dev/null; then
                    REPOSITORIES_JSON=$(echo "$REPOSITORIES_JSON" | jq --arg name "$TARGET_NAME" --arg branch "$NEW_BRANCH" \
                        '[.[] | if .name == $name then .branch = $branch else . end]')
                    print_success "브랜치 변경됨: $TARGET_NAME -> $NEW_BRANCH"
                else
                    print_warning "jq가 필요하거나 정보가 입력되지 않았습니다."
                fi

                display_repositories
                ;;

            6|*)
                # Done
                break
                ;;
        esac
    done
fi

# Handle case where no repos and no auto-detection in non-interactive
if [[ -z "$REPO_TYPE" && "$REPOSITORIES_JSON" == "[]" ]]; then
    if [[ "$READ_TIMEOUT" -eq 0 ]]; then
        print_info "비대화형 모드: 저장소가 설정되지 않았습니다."
    fi
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 3: Jira Project Configuration
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

print_header "📋 Jira 프로젝트 설정"

# Only prompt if not already set from environment variable
if [[ -z "$JIRA_PROJECT" ]]; then
    echo "Jira 프로젝트 키 (선택):"
    echo "  예시: PROJ, DEV, INFRA"
    read_with_default "프로젝트 키 (Enter=스킵): " "" "JIRA_PROJECT"
fi

if [[ -n "$JIRA_PROJECT" ]]; then
    print_success "Jira 프로젝트: $JIRA_PROJECT"
else
    print_info "Jira 프로젝트 설정을 건너뜁니다."
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 4: Retrospective Path
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

print_header "📁 회고록 저장 경로"

# RETRO_PATH is already initialized from environment variable with default
# Only prompt if in interactive mode and want to override
if [[ "$READ_TIMEOUT" -ne 0 ]]; then
    echo "회고록을 저장할 경로:"
    read_with_default "경로 [$RETRO_PATH]: " "$RETRO_PATH" "RETRO_PATH"
fi

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

    # Use environment variable or prompt
    if [[ -n "$ENV_MERGE_EXISTING" ]]; then
        REPLY="$ENV_MERGE_EXISTING"
        print_info "비대화형 모드: MERGE_EXISTING=$REPLY"
    else
        read_char_with_default "기존 설정과 병합하시겠습니까? (y/N): " "n" "REPLY"
    fi

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        EXISTING_SETTINGS=""
        BACKUP_FILE="$SETTINGS_FILE.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$SETTINGS_FILE" "$BACKUP_FILE"
        print_success "백업 생성됨: $BACKUP_FILE"
    fi
fi

# Create settings.local.json
if [[ -z "$EXISTING_SETTINGS" ]]; then
    # New file with error handling
    {
        cat > "$SETTINGS_FILE" <<EOF
{
  "productivityAgents": {
EOF
    } || {
        print_error "설정 파일 생성 실패: $SETTINGS_FILE"
        print_error "디스크 공간이 부족하거나 쓰기 권한이 없을 수 있습니다."
        exit 1
    }

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
    if [[ "$REPOSITORIES_JSON" != "[]" ]]; then
        # Format JSON nicely for the config file
        if command -v jq &> /dev/null; then
            FORMATTED_REPOS=$(echo "$REPOSITORIES_JSON" | jq -M '.')
        else
            FORMATTED_REPOS="$REPOSITORIES_JSON"
        fi
        cat >> "$SETTINGS_FILE" <<EOF
    "repositories": $FORMATTED_REPOS,
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
if [[ "$REPOSITORIES_JSON" != "[]" ]]; then
    echo "  - \"이 레포지토리의 지난 주 커밋 분석해줘\" (commit-retrospective)"
fi
echo ""

print_success "프로젝트 설정이 완료되었습니다!"
