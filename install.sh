#!/bin/bash
# Claude Code 설정 직접 설치 스크립트

set -e

CLAUDE_DIR="$HOME/.claude"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Claude Code 에이전트 설치 중..."

# agents 디렉토리 생성 및 복사
mkdir -p "$CLAUDE_DIR/agents"
cp -r "$SCRIPT_DIR/agents/"*.md "$CLAUDE_DIR/agents/"

echo ""
echo "설치 완료!"
echo ""
echo "설치된 에이전트:"
ls -1 "$CLAUDE_DIR/agents/"*.md 2>/dev/null | xargs -I {} basename {} | sed 's/\.md$//'
echo ""
echo "추가 플러그인을 설치하려면:"
echo "  claude mcp add anthropic-agent-skills -- npx -y @anthropic-ai/claude-code-mcp"
