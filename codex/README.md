# Codex Skills

이 디렉터리는 **OpenAI Codex** 전용 skill을 담고 있습니다.

이 repo는 Claude Code plugin과 OpenAI Codex skill이 공존하는 모노레포입니다.  
Claude plugin은 `plugins/` 디렉터리에, Codex skill은 이 `codex/` 디렉터리에 위치합니다.

---

## 현재 Skill 목록

| Skill 이름 | 설명 |
|------------|------|
| `mobidoc-ui-ux-beta` | Mobidoc 프런트엔드 UI/UX 베타 리뷰/가이드 — personal beta, 공식 팀 표준 아님 |

---

## 설치 방법

각 skill 디렉터리를 Codex의 skills 경로에 배치하세요:

```bash
cp -r codex/skills/<name>/ ~/.codex/skills/<name>/
```

예시:

```bash
cp -r codex/skills/mobidoc-ui-ux-beta/ ~/.codex/skills/mobidoc-ui-ux-beta/
```

설치 후 Codex에서 해당 skill 이름으로 호출할 수 있습니다.

---

## Codex Skill Frontmatter 규약

각 skill의 `SKILL.md`에는 다음 필드가 **필수**입니다:

```yaml
---
name: <skill-name>       # 필수: skill 식별자 (디렉터리명과 일치)
description: <설명>      # 필수: skill 목적 및 사용 조건 설명
---
```

`SKILL.md` 예시:

```yaml
---
name: mobidoc-ui-ux-beta
description: Mobidoc 프런트엔드 UI/UX 베타 리뷰 가이드. 공식 팀 표준 아님.
---
```

---

## Claude Plugin과의 관계

Claude Code 쪽 동등 기능은 다음에 위치합니다:

- **Claude Agent**: `plugins/frontend-agents/agents/mobidoc-ui-ux-reviewer.md`

두 소비자(Claude plugin 및 Codex skill)가 공유하는 UI/UX 가이드라인 파일
(`mobidoc-ui-ux-guidelines.md`)은 **직접 편집하지 마세요.**

해당 파일들은 `shared/references/`의 canonical 원본에서
`scripts/sync-shared.sh`로 자동 생성되는 **생성물(auto-generated copy)**입니다.

가이드라인을 수정하려면:

1. `shared/references/mobidoc-ui-ux-guidelines.md` (canonical) 을 편집합니다.
2. `scripts/sync-shared.sh` 를 실행하여 소비자 사본에 동기화합니다.

```bash
# canonical 편집 후 동기화
scripts/sync-shared.sh

# CI에서 드리프트 검사 (drift 발견 시 exit=1)
scripts/sync-shared.sh --check
```
