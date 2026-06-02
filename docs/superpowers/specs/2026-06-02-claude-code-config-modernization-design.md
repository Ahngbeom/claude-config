# Claude Code 설정 repo 현대화 설계

- **날짜**: 2026-06-02
- **대상 repo**: `claude-config` (Claude Code plugin marketplace)
- **접근법**: 구조화 모노레포 재편 (브레인스토밍 접근 B)
- **상태**: 설계 확정, 구현 계획 대기

## 1. 목표 (Goal)

이 repo를 Claude Code 최신 권장 규약에 맞게 현대화하되, **Claude Code와 OpenAI Codex skill이 한 repo에서 공존**하는 멀티에이전트 구조로 정식화한다. 구체적으로:

1. plugin/marketplace **메타데이터 규격** 정비 (version·keywords·license 등)
2. **Skill vs Command** 분류를 Claude Code 규약에 맞게 재정비
3. 26개 **Agent 정의 현대화** (color 정합·description 정리·model 티어 재조정)
4. **repo 구조/하우스키핑** (루트 산재 파일 정리, codex 영역 정식화, 공유 자산 단일화)
5. 위 규격이 유지되도록 **CI 검증** 추가

## 2. 비목표 (Non-Goals)

- 생성기/템플릿 레이어 도입 (접근 C) — 현재 규모(plugin 8 / agent 26)에 과설계.
- 에이전트 시스템 프롬프트(본문) 전면 재작성 — 이번엔 frontmatter/메타데이터 중심.
- 에이전트별 `tools` 제한 추가 — 전체 상속 유지, 컨벤션만 문서화.
- codex/write-docs 등 기능 중복 에이전트의 제거/통합 — `/write-docs`·`/write-tests`는 command로 유지.

## 3. 현 상태 진단 (Baseline)

- 마켓플레이스 1개(`.claude-plugin/marketplace.json`, `$schema`·category·homepage 보유).
- plugin 8개(agent 7 + `claude-hookify` 1). `claude-hookify`는 현재 **루트**에 위치.
- 개별 `plugin.json` 8개 전부 `name`·`description`·`author`만 보유 → `version`·`homepage`·`license`·`keywords` 없음.
- `productivity-agents/skills/` 4종(git-retro·jira-retro·write-docs·write-tests)은 `argument-hint`/`allowed-tools`/`context:fork`를 쓰는 **사실상 command**인데 `skills/<name>/SKILL.md`로 위치 → 분류 위반. write-docs·write-tests의 `context: fork`는 비표준 필드.
- agent 26개: model = sonnet 23 / haiku 3 / opus 0. color 12종 중 **gray·indigo·magenta·teal 4종이 비표준 enum**. description은 25/26이 `<example>` 패턴(권장)이나 YAML에 리터럴 `\n`으로 인코딩되어 가독성 낮음.
- 루트 산재: `notify.sh`·`stop-hook.sh`(스크립트), `COMPACT-STRATEGY.md`·`PROJECT-SETTINGS.md`·`settings.example.json`(문서/예시), `plugins/config.json`(repositories 설정).
- mobidoc UI/UX 가이드라인이 **두 사본으로 드리프트**: `codex/skills/mobidoc-ui-ux-beta/references/`(56행) vs `plugins/frontend-agents/references/`(62행), md5 상이.
- `.github` 없음 → CI 부재.
- 미커밋: `codex/`, `plugins/frontend-agents/agents/mobidoc-ui-ux-reviewer.md`, `plugins/frontend-agents/references/`, 수정된 `marketplace.json`·`README.md`·`frontend-agents/plugin.json`.

## 4. 목표 디렉터리 구조 (Target Architecture)

```
claude-config/
├── .claude-plugin/
│   └── marketplace.json          # Claude Code 마켓플레이스 (유지, source 경로 갱신)
├── plugins/                      # ── Claude Code 영역 ──
│   ├── README.md                 # plugin 카탈로그 (갱신)
│   ├── config.json               # repositories 설정 (유지)
│   ├── backend-agents/ … (7개 agent plugin)
│   └── claude-hookify/           # ← 루트에서 이동
├── codex/                        # ── OpenAI Codex 영역 ──
│   ├── README.md                 # NEW: Codex skill 규약·설치법·카탈로그
│   └── skills/
│       └── mobidoc-ui-ux-beta/
│           └── references/mobidoc-ui-ux-guidelines.md   # 동기화 생성물
├── shared/                       # NEW: 두 생태계 공유 자산
│   └── references/
│       └── mobidoc-ui-ux-guidelines.md   # canonical (단일 진실 원본)
├── scripts/                      # NEW
│   ├── notify.sh
│   ├── stop-hook.sh
│   ├── sync-shared.sh            # canonical → 소비자 동기화 (+--check)
│   └── validate.sh              # 규격 검증 (로컬/CI 공용)
├── docs/                         # NEW
│   ├── COMPACT-STRATEGY.md
│   ├── PROJECT-SETTINGS.md
│   ├── settings.example.json
│   └── superpowers/specs/        # 이 설계 문서 위치
├── .github/
│   └── workflows/validate.yml    # NEW: scripts/validate.sh 호출
├── LICENSE                       # NEW: MIT
├── CLAUDE.md                     # 유지 (경로/표 갱신)
└── README.md                     # 유지 (구조 반영)
```

## 5. 컴포넌트 설계

### 5.1 메타데이터 규격

각 `plugin.json` 표준:
```jsonc
{
  "name": "backend-agents",
  "version": "1.0.0",            // 전 plugin 1.0.0으로 시작
  "description": "...",
  "author": { "name": "ahngbeom", "email": "ahngbeom@github.com" },
  "homepage": "https://github.com/Ahngbeom/claude-config",
  "license": "MIT",
  "keywords": ["..."]            // plugin 도메인 키워드
}
```
- 루트 `LICENSE` = MIT, plugin license 필드와 일치.
- `marketplace.json`: `claude-hookify`의 `source`를 `./plugins/claude-hookify`로 갱신. 엔트리 `name`/설명을 plugin.json과 정합.
- Codex skill엔 plugin.json/version 개념 없음 → 버전·카탈로그는 `codex/README.md` 표로 관리.

### 5.2 Skill vs Command 재분류

| 유형 | 호출 | 위치 | 필수 frontmatter |
|------|------|------|------------------|
| Command | 사용자 `/name` | `commands/<name>.md` | `description` (+`argument-hint`/`allowed-tools` 선택) |
| Skill | 모델 자동 | `skills/<name>/SKILL.md` | `name`, `description` |

- `productivity-agents/skills/` 4종 → `plugins/productivity-agents/commands/<name>.md` 이동.
- frontmatter 정리: `name` 제거(파일명이 명령명), 비표준 `context: fork` 제거, `description`·`argument-hint`·`allowed-tools` 표준화.
- 빈 `skills/` 디렉터리 제거. CLAUDE.md "Available Skills (Slash Commands)" 표 경로 정합.
- write-docs·write-tests는 command로 **유지**(에이전트와 병존: 명시적 빠른 경로).

### 5.3 Agent 현대화 (26개)

목표 frontmatter:
```yaml
---
name: <파일명과 일치>
description: |                 # 블록 스칼라, 리터럴 \n 제거, <example>·키워드 보존
  ...
model: <haiku|sonnet|opus>     # 티어 재조정
color: <유효 enum만>
---
```
- **color 정합(필수)**: gray·indigo·magenta·teal → 유효 enum(red·blue·green·yellow·purple·orange·pink·cyan)으로 매핑. 매핑 초안: indigo→purple, magenta→pink, teal→cyan, gray→blue. (작업 시 시각 충돌 피해 확정.)
- **description**: 리터럴 `\n` → YAML 블록 스칼라로 가독성 정리, `<example>` 트리거 패턴/키워드 보존(의미 변경 없음).
- **model 티어 재조정**: 단순 변환·검증형(예: markdown-document-writer, retrospective-validator)→haiku, 무거운 추론형(예: backend-api-architect, ml-engineer, devops-engineer, database-expert)→opus 검토, 나머지 sonnet. 에이전트별 표로 확정 후 적용.
- `tools` 제한은 추가하지 않음(전체 상속 유지).

### 5.4 공유 자산 single source

제약: plugin/skill은 설치 시 자기 디렉터리만 번들 → 런타임 참조 파일은 소비자 디렉터리에 물리적으로 존재해야 함. 심링크는 패키징 시 깨질 위험.

전략 = **canonical + 동기화 + CI 드리프트 검사**:
```
shared/references/mobidoc-ui-ux-guidelines.md   (canonical, 편집 대상)
  └─ scripts/sync-shared.sh 가 복사 →
       plugins/frontend-agents/references/mobidoc-ui-ux-guidelines.md   (생성물)
       codex/skills/mobidoc-ui-ux-beta/references/mobidoc-ui-ux-guidelines.md (생성물)
```
- 소비자 사본 상단에 `<!-- AUTO-GENERATED from shared/references/... DO NOT EDIT -->`.
- canonical 초기값 = 현 두 사본의 **상위집합 병합**(62행 frontend 기준 + codex 고유 내용 reconcile).
- `sync-shared.sh --check`: 동기화 후 diff 있으면 비0 종료(CI에서 실패).
- `codex/README.md`: Codex skill 목록·설치 경로(`~/.codex/skills/` 등)·Claude plugin과의 관계·frontmatter 규약 문서화.

### 5.5 CI 검증

`scripts/validate.sh`(Bash + `jq`/`python3`)를 로컬·CI 공용으로 사용. `.github/workflows/validate.yml`은 이를 호출만.

검증 항목:
1. JSON 유효성 — marketplace.json, 모든 plugin.json, plugins/config.json.
2. plugin.json 필수 필드(name·version·description·author) 존재 + version이 semver.
3. marketplace ↔ plugin 일관성 — 각 `source` 경로 실재 + plugin.json `name` 일치.
4. Agent frontmatter — name(파일명 일치)·description·model·color 존재, `model ∈ {haiku,sonnet,opus}`, `color ∈ 유효 enum`.
5. Command frontmatter — `description` 존재, 비표준 필드 없음.
6. Skill frontmatter(codex 포함) — name·description 존재.
7. shared 동기화 — `sync-shared.sh --check` 통과(드리프트 없음).

## 6. 실행 단계 (Phasing)

각 단계는 독립 커밋/PR 가능. 순서 근거: 구조 이동 선행 → 경로 안정 후 메타/분류/에이전트 → 규격 확정 후 도구·CI.

- **Phase 0 — 미커밋 정리**: 현 미커밋 항목(codex/·mobidoc-ui-ux-reviewer·references·수정 manifest)의 의도 확인 후 베이스라인 커밋. 깨끗한 출발점 확보.
- **Phase 1 — 구조 재배치**: `claude-hookify`→`plugins/`, 루트 스크립트→`scripts/`, 문서→`docs/`, `shared/references/` 신설+canonical 병합. `git mv`로 이력 보존. marketplace.json·CLAUDE.md·README 경로 갱신.
- **Phase 2 — 메타데이터**: plugin.json 8개에 version·homepage·license·keywords 추가, 루트 LICENSE(MIT), marketplace 정합.
- **Phase 3 — Skill/Command 재분류**: skills 4종→commands 이동+frontmatter 정리, 빈 skills/ 제거, CLAUDE.md 표 정합.
- **Phase 4 — Agent 현대화**: 26개 color 정합·description 정리·model 티어 재조정. plugin 단위 분할 커밋 가능.
- **Phase 5 — 공유 자산 도구**: `sync-shared.sh`(+`--check`) 작성, 소비자 사본 생성·주석, `codex/README.md` 신설.
- **Phase 6 — CI**: `validate.sh` 작성, `.github/workflows/validate.yml` 호출, 전 규격 검사.
- **Phase 7 — 문서 마무리**: 루트 README·CLAUDE.md·plugins/README·docs/ 최종 구조 반영, `validate.sh` 전체 통과 확인.

## 7. 검증 (Verification)

- 각 Phase 후 `git status` 확인, 이력 보존(`git mv`) 확인.
- Phase 6 이후 `scripts/validate.sh` 전체 통과 = 완료 기준.
- 동기화: canonical 수정→`sync-shared.sh`→`--check` 무 diff.
- 회귀: 기존 marketplace install 경로(`source`)가 모두 유효한지 CI 항목 3으로 보장.

## 8. 위험 및 완화 (Risks)

- **경로 이동에 따른 참조 깨짐**: marketplace `source`, agent의 `../references/...` 상대경로, CLAUDE.md/README 링크. → Phase 1에서 일괄 갱신 + CI 항목 3/7로 검출.
- **mobidoc canonical 병합 시 내용 손실**: 두 사본 상위집합 병합 시 diff 수동 검토 필수.
- **color 매핑 시 시각 충돌**: 같은 plugin 내 동일 색 중복 가능 → 매핑 시 plugin별 분포 확인.
- **PR 비대화**: Phase 4(26개)가 큼 → plugin 단위 커밋으로 분할.

## 9. 확정된 결정 (Decisions)

| 항목 | 결정 |
|------|------|
| repo 정체성 | Claude + Codex 멀티에이전트 공존 |
| 개편 범위 | 메타데이터·Skill/Command·Agent·구조 전체 |
| claude-hookify 위치 | `plugins/`로 이동 |
| shared/ 신설 | 채택 |
| plugin version 시작값 | 전부 1.0.0 |
| license | MIT (루트 LICENSE 파일) |
| write-docs/write-tests | command로 유지 |
| model 티어 재조정 | 범위에 포함 |
| 공유 자산 전략 | canonical + sync 스크립트 + CI 드리프트 검사 |
| 검증 자동화 | CI 포함, 스크립트는 Bash + jq/python3 |
