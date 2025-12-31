# Claude Code 토큰 사용 최적화 - Compact 전략

## 목표

Claude Code 사용 시 효율적인 컨텍스트 관리와 비용 절감 전략 수립

## 핵심 발견: Auto-Compact의 실제 효과

### ⚠️ 중요한 구분

| 개념 | 설명 | Auto-Compact 효과 |
|------|------|-------------------|
| **토큰 절감** | API 호출 시 토큰 수 감소 | ❌ 없음 (요약 자체가 토큰 소비) |
| **컨텍스트 관리** | 200K 윈도우 내 유지 | ✅ 효과적 |
| **간접 비용 절감** | 세션 재시작/프리미엄 티어 회피 | ✅ 효과적 |

### Auto-Compact가 하는 것
- 컨텍스트 윈도우 95% 도달 시 대화 요약
- 요약으로 컨텍스트 공간 확보 (150K → 30-50K)
- 긴 세션 유지 가능하게 함

### Auto-Compact가 하지 않는 것
- API 요청의 총 토큰 수 감소
- 요약 과정의 토큰 비용 절감 (요약 생성에 토큰 소비됨)
- 단기적 비용 절감

### 실제 비용 절감이 발생하는 경우
1. **긴 세션 유지**: 새 세션 시작보다 compact 후 계속이 저렴
2. **1M 프리미엄 회피**: 200K 초과 시 입력 토큰 2배 요금 ($3 → $6/MTok)
3. **히스토리 재처리 방지**: 같은 컨텍스트 재전송 회피

## 현재 상황 분석

### Claude Code 토큰 사용 구조

1. **컨텍스트 윈도우**: 약 200K 토큰 (1M 베타 가능)
2. **자동 compact**: 95% 도달 시 자동 요약
3. **수동 compact**: `/compact [instructions]` 명령어
4. **백그라운드 소비**: 세션당 약 $0.04 미만 (요약, 명령 처리)

### 토큰 소비 요인

| 요인 | 설명 | 영향도 |
|------|------|--------|
| 대화 히스토리 | 누적된 질문/응답 | 높음 |
| 코드베이스 스캔 | Glob, Grep, Read 작업 | 높음 |
| 파일 내용 로딩 | 읽은 파일 컨텍스트 | 중간 |
| CLAUDE.md | 프로젝트/사용자 메모리 | 낮음 |
| Extended thinking | 내부 추론 (설정 시) | 가변 |
| **Compact 요약** | 요약 생성 토큰 | 중간 |

## 최적화 전략

### 전략 1: Compact 최적화

#### 1.1 수동 Compact 활용
```bash
# 기본 compact
/compact

# 특정 컨텍스트 보존
/compact Focus on code changes and test results
/compact Keep error messages and debugging info
/compact Retain security-related changes
```

#### 1.2 CLAUDE.md 요약 지침 설정
```markdown
# Summary instructions

When you are using compact, please focus on:
- Code changes and implementations
- Test output and error messages
- API modifications
- Architectural decisions
```

#### 1.3 PreCompact 훅 활용
```json
{
  "hooks": {
    "PreCompact": [
      {
        "matcher": "auto",
        "hooks": [
          {
            "type": "command",
            "command": "echo 'Auto-compact triggered' >> ~/.claude/compact.log"
          }
        ]
      }
    ]
  }
}
```

### 전략 2: 작업 패턴 최적화

#### 2.1 명확한 질의 작성
❌ 피해야 할 패턴:
- "이 코드 최적화해줘"
- "버그 찾아줘"
- "개선해줘"

✅ 권장 패턴:
- "UserService.ts의 데이터베이스 쿼리 최적화해줘"
- "login() 함수에서 null 체크 누락 버그 수정해줘"
- "src/api/auth.ts:45 에러 핸들링 추가해줘"

#### 2.2 파일 직접 참조
```bash
# 직접 참조 (토큰 절약)
@src/components/Button.tsx

# 대신 Claude가 찾게 하기 (토큰 낭비)
"Button 컴포넌트 찾아서 수정해줘"
```

#### 2.3 작업 분할
```
대규모 리팩토링 작업:
1. /clear → 새 세션 시작
2. 하나의 모듈/파일에 집중
3. 완료 후 /compact
4. 다음 모듈로 이동
```

### 전략 3: 세션 관리

#### 3.1 세션 초기화 시점
- 완전히 다른 작업으로 전환 시: `/clear`
- 같은 프로젝트 내 다른 기능 작업 시: `/compact`
- 컨텍스트 80%+ 도달 시: `/compact`

#### 3.2 세션 재개 활용
```bash
# 이전 세션 재개 (요약된 컨텍스트 활용)
claude --resume

# 특정 세션 재개
claude --resume <session-id>
```

### 전략 4: 설정 최적화

#### 4.1 Auto-compact 설정
```json
// ~/.claude/settings.json
{
  "autoCompactEnabled": true
}
```

#### 4.2 Extended Thinking 제어
```bash
# 필요 시에만 활성화
export MAX_THINKING_TOKENS=1024  # 제한적 사용
export MAX_THINKING_TOKENS=0     # 비활성화
```

## 권장 워크플로우

### 일일 작업 플로우

```
1. 작업 시작
   └─ claude 시작 (새 세션)

2. 작업 진행
   ├─ 명확한 질의 작성
   ├─ @file 직접 참조
   └─ 컨텍스트 모니터링 (/context)

3. 컨텍스트 80% 도달
   └─ /compact [현재 작업 관련 지침]

4. 작업 전환
   ├─ 같은 프로젝트: /compact
   └─ 다른 프로젝트: /clear

5. 작업 종료
   └─ 세션 종료 (자동 요약됨)

6. 다음 날
   └─ claude --resume (필요 시)
```

### 대규모 작업 플로우

```
1. 계획 수립
   └─ 작업 모듈 단위 분할

2. 모듈별 작업
   ├─ /clear (새 세션)
   ├─ 단일 모듈 집중 작업
   ├─ 테스트 및 검증
   └─ 커밋

3. 다음 모듈
   └─ 2단계 반복
```

## 모니터링

### 사용량 추적 명령어
```bash
/cost      # 현재 세션 비용
/context   # 컨텍스트 사용량 시각화
```

### statusline.sh 통합 (이미 구현됨)
```
🧠 Context: 42.5K / 200K (79%) [========--]
⏱️ Session: 25.7M | 2h 12m [====------] (Cache: 93%, Speed: 156.4K/min)
```

## 예상 효과 (현실적 평가)

### 직접 효과 (측정 가능)
| 항목 | 개선 내용 |
|------|----------|
| 컨텍스트 효율 | 불필요한 히스토리 제거로 공간 확보 |
| 세션 연속성 | 긴 작업에서 중단 없이 진행 |
| 요약 품질 | CLAUDE.md 지침으로 중요 정보 보존 |

### 간접 효과 (비용 절감)
| 상황 | 절감 효과 |
|------|----------|
| 긴 세션 (2시간+) | 세션 재시작 비용 회피 |
| 200K 초과 방지 | 1M 프리미엄 요금 회피 ($3 → $6/MTok) |
| 히스토리 재처리 | 같은 컨텍스트 재전송 방지 |

### ⚠️ 오해 방지
- Compact 자체는 토큰을 소비함 (절감 아님)
- 짧은 세션에서는 효과 미미
- 핵심은 "토큰 절감"이 아닌 "효율적 컨텍스트 관리"

## 적용 체크리스트 (필요 시 참고)

### 즉시 적용 가능한 습관
- [ ] 명확한 질의 작성 (파일/함수 명시)
- [ ] `@파일경로` 직접 참조 사용
- [ ] 컨텍스트 80% 도달 시 수동 `/compact`
- [ ] 작업 전환 시 `/clear` 또는 `/compact` 선택

### 선택적 설정 변경 (적용 시)
- [ ] `~/.claude/CLAUDE.md`에 Summary Instructions 추가
- [ ] `settings.json`에 `autoCompactEnabled: true` 확인
- [ ] PreCompact 훅으로 compact 로그 기록 (디버깅용)

---

*문서 작성일: 2025-12-18*
*위치: ~/.claude/docs/compact-strategy.md*
