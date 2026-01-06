#!/bin/bash
# Claude Code Stop Hook - 작업 요약 알림
# stdin으로 받은 JSON에서 transcript_path를 추출하여 작업 내용 분석

input=$(cat)
transcript_path=$(echo "$input" | jq -r '.transcript_path')

# 기본값
edit_count=0
write_count=0
bash_count=0

# transcript 파일이 존재하면 분석
if [ -f "$transcript_path" ]; then
    edit_count=$(grep -c '"tool_name".*"Edit"' "$transcript_path" 2>/dev/null || echo 0)
    write_count=$(grep -c '"tool_name".*"Write"' "$transcript_path" 2>/dev/null || echo 0)
    bash_count=$(grep -c '"tool_name".*"Bash"' "$transcript_path" 2>/dev/null || echo 0)
fi

# 요약 생성
file_total=$((edit_count + write_count))
summary_parts=()

if [ "$file_total" -gt 0 ]; then
    summary_parts+=("파일 ${file_total}개 수정")
fi

if [ "$bash_count" -gt 0 ]; then
    summary_parts+=("명령어 ${bash_count}회 실행")
fi

# 요약이 없으면 기본 메시지
if [ ${#summary_parts[@]} -eq 0 ]; then
    summary=""
else
    summary=$(IFS=', '; echo "${summary_parts[*]}")
fi

# 알림 전송
~/.claude/notify.sh "Claude Code" "작업 완료" "$summary"
