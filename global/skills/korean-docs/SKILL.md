---
name: korean-docs
description: Use when writing or revising Korean prose for human readers — MR/PR 본문, Jira 이슈·코멘트, 장애 보고서, 분석·비교, 의사결정 기록, 설계 문서, README, 런북, 가이드. Not for commit messages, Slack messages, code comments, or English documents.
---

# 한국어 문서 작성

사람이 읽는 한국어 글을 채널 독자에 맞는 고정 골격과 일관된 문체로 쓴다. 채널별 독자, 첫머리, 제외 항목의 원본은 `~/.claude/CLAUDE.md` "Audience by Channel"이며, 이 스킬은 그 규칙을 골격과 문체로 실행한다.

## 문서 종류와 템플릿

| 쓰려는 글 | 읽을 파일 |
|---|---|
| MR/PR 본문 | `templates/mr-pr.md` |
| Jira 이슈 (버그, 작업 요청) | `templates/jira-issue.md` |
| Jira 코멘트 (진행, 완료) | `templates/jira-comment.md` |
| 장애 보고, 분석·비교, 의사결정 | `templates/report.md` |
| README, 설계 문서, 런북, 가이드 | `templates/tech-doc.md` |
| 위에 없는 글 | `references/layout.md`의 기본 골격 |

## 절차

1. 종류를 판별하고 해당 템플릿 하나만 읽는다.
2. `references/style.md`와 `references/layout.md`를 읽는다.
3. 다이어그램이 나을지 `~/.claude/CLAUDE.md` Visuals 규칙으로 판단한다.
4. 골격을 채워 초안을 쓴다. 입력에 없는 값은 "확인 필요"로 남기고, 입력에 이름만 있는 코드의 동작이나 입력에 없는 인과는 쓰지 않는다(`style.md` 사실 범위).
5. `references/checklist.md`의 모든 항목에 답하고, '아니오'를 고친 뒤 제출한다.

사용자가 섹션 구성이나 어미를 직접 지정하면 그 지정이 템플릿보다 우선한다. 문체와 검수 규칙은 그대로 적용한다.

## 핵심 규칙

- 결과, 결정, 요청 중 하나를 첫 3줄 안에 쓴다.
- 한 문서 안에서 서술 어미를 섞지 않는다.
- 번역투(`~에 대해`, `~를 가지다`, `~되어지다`, `~하는 것이 가능하다`)를 쓰지 않는다.
- 같은 형식이 반복되는 정보는 표나 목록으로 쓰고, 문단은 3문장을 넘기지 않는다.
- '완료'라고 쓴 항목에는 확인 방법을 붙이고, 확인하지 않았으면 그렇게 쓴다.
