# 쉘 스크립트 레퍼런스

Claude Code 환경의 쉘 스크립트 상세 가이드입니다.

## 목차

- [개요](#개요)
- [statusline.sh](#statuslinesh)
- [notify.sh](#notifysh)
- [stop-hook.sh](#stop-hooksh)
- [activate-hooks.sh](#activate-hookssh)
- [커스터마이징](#커스터마이징)
- [트러블슈팅](#트러블슈팅)

---

## 개요

### 설치된 스크립트

| 스크립트 | 용도 | 라인 수 |
|---------|------|--------|
| `statusline.sh` | 상태 표시줄 커스터마이징 | ~439줄 |
| `notify.sh` | 크로스 플랫폼 알림 시스템 | ~31줄 |
| `stop-hook.sh` | 세션 종료 시 작업 요약 알림 | ~41줄 |
| `activate-hooks.sh` | Hookify 규칙 활성화 도우미 | ~17줄 |

### 실행 권한 부여

```bash
chmod +x ~/.claude/*.sh
```

---

## statusline.sh

**목적:** Claude Code 하단에 표시되는 상태 표시줄 커스터마이징

### 표시 정보

#### Line 1: 핵심 정보
```
📁 ~/project  🌿 main  🤖 Sonnet 4  🏷️ 20250929  📟 v1.2.3  🎨 explanatory
```

- **디렉토리**: 현재 작업 디렉토리 (`~` 약어 사용)
- **Git 브랜치**: 현재 브랜치 또는 커밋 해시
- **모델 이름**: Claude Sonnet 4 / Opus 4 / Haiku 3.5
- **모델 버전**: 모델 식별자
- **Claude Code 버전**: CLI 도구 버전
- **출력 스타일**: explanatory / learning 등

#### Line 2: 컨텍스트 정보
```
🧠 Context: 45.2K / 200K (77%) [=======---] (Cache: 93%, Speed: 156.4K/min)
```

- **사용량**: 현재 / 최대 토큰 (K/M 단위)
- **남은 비율**: 컨텍스트 여유 공간
- **진행 바**: 10칸 게이지 (`=` 사용, `-` 남음)
- **캐시 히트율**: 캐시 읽기 비율
- **속도**: 분당 토큰 처리 속도

**색상 코딩:**
- 🟢 녹색 (60%+ 남음)
- 🟡 노란색 (40-60% 남음)
- 🔴 빨간색 (20% 이하 남음)

#### Line 3: 세션 정보
```
⏱️ Session: 25.7M tokens | Reset: 2h 15m [======----]
```

- **총 토큰**: 현재 세션 누적 토큰
- **리셋까지 시간**: 5시간 블록 남은 시간
- **진행 바**: 세션 진행률

#### Line 4: 사용량 통계
```
📅 Today: 125.3M ($3.52)  📆 Week: 542.1M ($15.28)  🗓️ Month: 2.1B ($59.43)
```

- **오늘**: 일일 토큰 및 비용
- **이번 주**: 주간 토큰 및 비용
- **이번 달**: 월간 토큰 및 비용

### 작동 원리

#### 1. 입력 받기
```bash
input=$(cat)  # stdin으로 JSON 수신
```

#### 2. 모델별 컨텍스트 윈도우 결정
```bash
get_max_context() {
  case "$model_name" in
    *"Opus"*|*"Sonnet"*|*"Haiku"*)
      echo "200000"  # 200K
      ;;
    *)
      echo "200000"
      ;;
  esac
}
```

#### 3. 컨텍스트 계산
```bash
# 세션 파일에서 최신 토큰 수 읽기
session_file="$HOME/.claude/projects/-${project_dir}/${session_id}.jsonl"
latest_tokens=$(tail -20 "$session_file" | jq -r 'select(.message.usage) | ...')
```

#### 4. ccusage 통합 (캐싱)
```bash
# 60초 캐시
CACHE_FILE="$HOME/.claude/stats-cache.json"
CACHE_TTL=60

# 캐시 히트 시 즉시 반환
cached_data=$(read_cache)

# 캐시 미스 시 백그라운드 업데이트
update_cache_background
```

### 커스터마이징

#### 색상 변경

```bash
# statusline.sh 편집
dir_color() { printf '\033[38;5;117m'; }    # 하늘색 → 원하는 색상 코드
model_color() { printf '\033[38;5;147m'; }  # 연보라 → 변경
```

**256 Color 코드 참조:**
- 117: 하늘색
- 147: 연보라
- 150: 연초록
- 203: 산호색
- 215: 복숭아색

#### 표시 항목 추가/제거

```bash
# Line 1에 프로젝트 이름 추가
project_name="My Project"
printf '  📦 %s' "$project_name"

# Line 4에서 월간 통계 제거
# 해당 섹션 주석 처리 또는 삭제
```

### 의존성

- `jq`: JSON 파싱 (필수)
- `ccusage`: 사용량 통계 (선택)
  ```bash
  npm install -g ccusage
  ```

---

## notify.sh

**목적:** 크로스 플랫폼 알림 전송

### 사용법

```bash
~/.claude/notify.sh "제목" "메시지" ["요약"]
```

**예시:**
```bash
notify.sh "Claude Code" "작업 완료"
notify.sh "테스트" "테스트 실패" "5개 중 2개 실패"
```

### 플랫폼별 구현

#### macOS
```bash
osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\" sound name \"Glass\""
```

**사운드 옵션:**
- `Glass` (기본)
- `Ping`
- `Hero`
- `Submarine`

#### Linux
```bash
notify-send "$TITLE" "$MESSAGE"
```

**요구사항:**
- `libnotify` 패키지

**설치:**
```bash
# Ubuntu/Debian
sudo apt-get install libnotify-bin

# Fedora/RHEL
sudo dnf install libnotify
```

#### Windows
```bash
powershell.exe -Command "[Windows.UI.Notifications.ToastNotificationManager, ...]"
```

**지원 환경:**
- Git Bash
- MSYS2
- Cygwin

### 커스터마이징

#### macOS 사운드 변경
```bash
# notify.sh 편집
osascript -e "... sound name \"Ping\""  # Glass → Ping
```

#### Linux 아이콘 추가
```bash
notify-send -i /path/to/icon.png "$TITLE" "$MESSAGE"
```

#### 지속 시간 설정 (Linux)
```bash
notify-send -t 5000 "$TITLE" "$MESSAGE"  # 5초
```

---

## stop-hook.sh

**목적:** 세션 종료 시 작업 요약 알림 전송

### 작동 흐름

1. **Transcript 분석**
   ```bash
   transcript_path=$(echo "$input" | jq -r '.transcript_path')
   ```

2. **도구 사용 카운트**
   ```bash
   edit_count=$(grep -c '"tool_name".*"Edit"' "$transcript_path")
   write_count=$(grep -c '"tool_name".*"Write"' "$transcript_path")
   bash_count=$(grep -c '"tool_name".*"Bash"' "$transcript_path")
   ```

3. **요약 생성**
   ```bash
   "파일 5개 수정, 명령어 3회 실행"
   ```

4. **알림 전송**
   ```bash
   ~/.claude/notify.sh "Claude Code" "작업 완료" "$summary"
   ```

### 출력 예시

```
제목: Claude Code
메시지: 작업 완료
요약: 파일 12개 수정, 명령어 8회 실행
```

### 커스터마이징

#### 추가 통계 수집

```bash
# Grep 사용 횟수 추가
grep_count=$(grep -c '"tool_name".*"Grep"' "$transcript_path" 2>/dev/null || echo 0)

if [ "$grep_count" -gt 0 ]; then
    summary_parts+=("검색 ${grep_count}회")
fi
```

#### 조건부 알림

```bash
# 10개 이상 파일 수정 시만 알림
if [ "$file_total" -ge 10 ]; then
    ~/.claude/notify.sh "Claude Code" "대규모 작업 완료" "$summary"
fi
```

#### 시간 추적

```bash
# transcript 첫 줄과 마지막 줄 시간 비교
start_time=$(head -1 "$transcript_path" | jq -r '.timestamp')
end_time=$(tail -1 "$transcript_path" | jq -r '.timestamp')
duration=$((end_time - start_time))
summary_parts+=("소요시간 ${duration}초")
```

---

## activate-hooks.sh

**목적:** Hookify 규칙 활성화 도우미

### 사용법

```bash
~/.claude/activate-hooks.sh
```

### 출력

```
🔧 Hookify 규칙을 활성화합니다...

📋 현재 등록된 Hookify 규칙:
- prefer-git-committer (enabled)
- prefer-frontend-engineer (enabled)
- prefer-backend-agent (enabled)

💡 규칙 활성화/비활성화하려면:
   claude hookify configure

✅ 설정이 완료되었습니다.
```

### 확장

#### 자동 활성화

```bash
# 모든 규칙 자동 활성화
for rule in ~/.claude/hookify.*.local.md; do
    rule_name=$(basename "$rule" .local.md | sed 's/^hookify\.//')
    echo "✅ $rule_name 활성화"
done
```

#### 선택적 활성화

```bash
# 대화형 선택
echo "활성화할 규칙을 선택하세요:"
select rule in prefer-git-committer prefer-frontend-engineer; do
    echo "✅ $rule 활성화됨"
    break
done
```

---

## 커스터마이징

### 새 스크립트 추가

#### 1. 스크립트 생성

```bash
cat > ~/.claude/my-script.sh << 'EOF'
#!/bin/bash
# My Custom Script

echo "Hello from my script!"
EOF

chmod +x ~/.claude/my-script.sh
```

#### 2. settings.json에 등록

```json
{
  "hooks": {
    "SessionStart": [{
      "hooks": [{
        "type": "command",
        "command": "~/.claude/my-script.sh"
      }]
    }]
  }
}
```

### 유용한 커스텀 스크립트 예시

#### 세션 시작 로그

```bash
#!/bin/bash
# session-start.sh

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Session started" >> ~/.claude/session.log
```

#### Git 상태 확인

```bash
#!/bin/bash
# git-check.sh

if git diff --quiet && git diff --cached --quiet; then
    echo "✅ Working tree clean"
else
    echo "⚠️  Uncommitted changes detected"
    git status --short
fi
```

#### 컨텍스트 경고

```bash
#!/bin/bash
# context-warning.sh

input=$(cat)
context_pct=$(echo "$input" | jq -r '.context_percentage // 0')

if [ "$context_pct" -gt 80 ]; then
    ~/.claude/notify.sh "Context Warning" "컨텍스트 ${context_pct}% 사용 중"
fi
```

---

## 트러블슈팅

### Q: statusline.sh가 표시되지 않아요

**A: 실행 권한 확인**
```bash
chmod +x ~/.claude/statusline.sh
~/.claude/statusline.sh  # 수동 실행 테스트
```

**A: settings.json 확인**
```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh"
  }
}
```

**A: jq 설치 확인**
```bash
which jq
# 없으면 설치
brew install jq  # macOS
sudo apt-get install jq  # Ubuntu
```

### Q: notify.sh 알림이 오지 않아요

**A: macOS 권한 확인**
- 시스템 환경설정 → 알림 → 터미널 허용

**A: Linux 패키지 확인**
```bash
notify-send "Test" "Message"
# 실패 시 설치
sudo apt-get install libnotify-bin
```

**A: 수동 테스트**
```bash
~/.claude/notify.sh "Test" "This is a test"
```

### Q: stop-hook.sh가 작동하지 않아요

**A: Hook 설정 확인**
```json
{
  "hooks": {
    "Stop": [{
      "hooks": [{
        "type": "command",
        "command": "~/.claude/stop-hook.sh"
      }]
    }]
  }
}
```

**A: transcript 경로 확인**
```bash
# stop-hook.sh에 디버깅 추가
echo "Transcript: $transcript_path" >> ~/hook-debug.log
```

### Q: ccusage 데이터가 표시되지 않아요

**A: ccusage 설치**
```bash
npm install -g ccusage

# 또는 npx 사용 (statusline.sh에서 자동 처리)
```

**A: 캐시 삭제**
```bash
rm ~/.claude/stats-cache.json
```

### Q: 스크립트 실행 시 오류가 발생해요

**A: 쉘 스크립트 문법 확인**
```bash
bash -n ~/.claude/statusline.sh  # 문법 검사
```

**A: 로그 확인**
```bash
~/.claude/statusline.sh 2>&1 | tee ~/statusline-error.log
```

---

## 참고 자료

- [Hookify 규칙 가이드](./hookify-rules-guide.md)
- [빠른 시작 가이드](./quick-start.md)
- [ccusage 도구](https://www.npmjs.com/package/ccusage)
- [ANSI 색상 코드](https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit)

---

*문서 작성일: 2026-01-07*
*위치: ~/.claude/docs/shell-scripts-reference.md*
