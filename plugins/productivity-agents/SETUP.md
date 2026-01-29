# Productivity Agents 설정 가이드

Productivity Agents 플러그인 사용을 위한 초기 환경 설정 가이드입니다.

---

## 📋 목차

- [빠른 시작](#빠른-시작)
- [에이전트 소개](#에이전트-소개)
- [전역 설정](#전역-설정)
- [프로젝트별 설정](#프로젝트별-설정)
- [수동 설정](#수동-설정)
- [설정 검증](#설정-검증)
- [트러블슈팅](#트러블슈팅)
- [FAQ](#faq)

---

## 🚀 빠른 시작

### 1단계: 전역 설정 (필수)

플러그인 디렉토리에서 초기화 스크립트를 실행합니다:

```bash
cd ~/.claude/plugins/marketplaces/ahngbeom-claude-config/plugins/productivity-agents
./setup/init.sh
```

대화형 프롬프트에 따라 다음 정보를 입력합니다:
- **Atlassian (Jira)**: URL, Email, API Token
- **GitHub**: Username, Email
- **GitLab**: URL, Username, Email (선택)
- **회고록 저장 경로**

### 2단계: 프로젝트 설정 (선택)

프로젝트별로 레포지토리 정보를 설정하려면:

```bash
cd /your/project
~/.claude/plugins/marketplaces/ahngbeom-claude-config/plugins/productivity-agents/setup/init-project.sh
```

### 3단계: 설정 검증

설정이 올바른지 확인합니다:

```bash
cd ~/.claude/plugins/marketplaces/ahngbeom-claude-config/plugins/productivity-agents
./setup/validate.sh
```

### 4단계: 에이전트 사용

Claude Code에서 다음과 같이 요청하세요:

```
"지난 주 회고록 작성해줘"           # jira-retrospective
"이번 주 내 커밋 회고록 작성해줘"   # commit-retrospective
```

---

## 🤖 에이전트 소개

### jira-retrospective

**기능**: Jira 이슈를 자동으로 검색하고 회고록을 생성합니다.

**필수 설정**:
- Atlassian URL
- API Token
- Account ID (자동 조회 가능)

**사용 예시**:
```
"지난 주 회고록 작성해줘"
"이번 달 PROJ 프로젝트 진행 현황 정리해줘"
```

### commit-retrospective

**기능**: Git 커밋 히스토리를 분석하고 회고록을 생성합니다.

**필수 설정**:
- Git author name/email (자동 감지 가능)
- 레포지토리 경로 (선택)

**사용 예시**:
```
"이번 주 내 커밋 분석해줘"
"지난 달 이 레포지토리의 작업 내역 정리해줘"
```

### test-automation-engineer

**기능**: 단위/컴포넌트/E2E 테스트를 자동으로 작성합니다.

**필수 설정**: 없음 (프로젝트 의존성 자동 감지)

**사용 예시**:
```
"이 컴포넌트에 대한 테스트 작성해줘"
"Jest 테스트 추가해줘"
```

### markdown-document-writer

**기능**: 마크다운 문서를 작성하고 구조화합니다.

**필수 설정**: 없음

**사용 예시**:
```
"README.md 작성해줘"
"API 문서 생성해줘"
```

---

## 🌐 전역 설정

### 설정 파일 위치

```
~/.claude/
├── productivity-agents.json   # 사용자 계정 정보
├── .env                       # API 토큰 (민감 정보)
└── retrospectives/            # 회고록 저장 디렉토리
```

### productivity-agents.json 구조

```json
{
  "$schema": "https://raw.githubusercontent.com/Ahngbeom/claude-config/main/plugins/productivity-agents/.claude-plugin/settings-schema.json",
  "atlassian": {
    "defaultUrl": "yourcompany.atlassian.net",
    "user": {
      "accountId": "63f2ca0f89de3d475af37c31",
      "email": "user@company.com",
      "displayName": "Your Name"
    }
  },
  "github": {
    "defaultUrl": "github.com",
    "user": {
      "username": "yourname",
      "email": "user@company.com"
    }
  },
  "gitlab": {
    "defaultUrl": "gitlab.com",
    "user": {
      "username": "yourname",
      "email": "user@company.com"
    }
  },
  "output": {
    "retrospectivePath": "~/.claude/retrospectives"
  }
}
```

### .env 파일 구조

```bash
# Atlassian (Jira) Configuration
ATLASSIAN_URL=yourcompany.atlassian.net
ATLASSIAN_EMAIL=user@company.com
ATLASSIAN_API_TOKEN=your_api_token_here

# GitHub Configuration (Optional)
GITHUB_TOKEN=ghp_xxxxxxxxxxxxx

# GitLab Configuration (Optional)
GITLAB_URL=gitlab.com
GITLAB_TOKEN=glpat-xxxxxxxxxxxxx
```

### API 토큰 생성 방법

#### Atlassian (Jira)

1. https://id.atlassian.com/manage-profile/security/api-tokens 접속
2. "Create API token" 클릭
3. 토큰 이름 입력 (예: "claude-productivity-agents")
4. 생성된 토큰을 복사하여 `.env` 파일에 저장

#### GitHub

1. https://github.com/settings/tokens 접속
2. "Generate new token (classic)" 클릭
3. 스코프 선택: `repo`, `read:org`
4. 생성된 토큰을 복사하여 `.env` 파일에 저장

#### GitLab

1. https://gitlab.com/-/profile/personal_access_tokens 접속
2. 토큰 이름 입력 및 만료일 설정
3. 스코프 선택: `read_api`, `read_repository`
4. 생성된 토큰을 복사하여 `.env` 파일에 저장

---

## 📁 프로젝트별 설정

### 설정 파일 위치

```
<project>/
├── .claude/
│   └── settings.local.json   # 프로젝트별 설정
├── .gitignore                # 민감 정보 제외
└── docs/
    └── retrospectives/       # 회고록 저장 (프로젝트별)
```

### settings.local.json 구조

```json
{
  "productivityAgents": {
    "jira": {
      "project": "PROJ",
      "defaultAssignee": "use-global"
    },
    "repositories": [
      {
        "name": "main",
        "type": "github",
        "owner": "company",
        "repo": "project-name",
        "branch": "main"
      }
    ],
    "output": {
      "retrospectivePath": "./docs/retrospectives"
    }
  }
}
```

### 설정 우선순위

프로젝트 설정이 전역 설정보다 우선합니다:

1. **프로젝트 설정** (`.claude/settings.local.json`)
2. **전역 설정** (`~/.claude/productivity-agents.json`)

---

## ⚙️ 수동 설정

자동 스크립트 없이 수동으로 설정할 수도 있습니다.

### 1. 전역 설정 파일 생성

```bash
mkdir -p ~/.claude
touch ~/.claude/productivity-agents.json
touch ~/.claude/.env
chmod 600 ~/.claude/.env
```

### 2. 템플릿 복사

```bash
cp ~/.claude/plugins/marketplaces/ahngbeom-claude-config/plugins/productivity-agents/setup/templates/productivity-agents.json.template \
   ~/.claude/productivity-agents.json

cp ~/.claude/plugins/marketplaces/ahngbeom-claude-config/plugins/productivity-agents/setup/templates/.env.template \
   ~/.claude/.env
```

### 3. 설정 파일 편집

에디터로 파일을 열어 정보를 입력합니다:

```bash
nano ~/.claude/productivity-agents.json
nano ~/.claude/.env
```

### 4. 회고록 디렉토리 생성

```bash
mkdir -p ~/.claude/retrospectives
```

---

## ✅ 설정 검증

### 자동 검증

```bash
cd ~/.claude/plugins/marketplaces/ahngbeom-claude-config/plugins/productivity-agents
./setup/validate.sh
```

검증 항목:
- ✓ 설정 파일 존재 확인
- ✓ JSON 스키마 검증
- ✓ 환경 변수 확인
- ✓ Git 설정 확인
- ✓ 저장 경로 접근 권한 확인

### 수동 검증

#### 1. 설정 파일 확인

```bash
cat ~/.claude/productivity-agents.json
```

#### 2. 환경 변수 확인

```bash
grep ATLASSIAN ~/.claude/.env
```

#### 3. Git 설정 확인

```bash
git config user.name
git config user.email
```

#### 4. MCP 연결 테스트 (Atlassian)

Claude Code에서 다음을 실행:

```
"Jira에서 최근 이슈 1개 조회해줘"
```

---

## 🔧 트러블슈팅

### Atlassian MCP 연결 실패

**증상**: Jira 이슈를 조회할 수 없음

**원인**:
- API 토큰이 잘못되었거나 만료됨
- Jira URL이 올바르지 않음
- Account ID가 잘못됨

**해결 방법**:

1. API 토큰 재생성:
   ```bash
   # 새로운 API 토큰 생성
   # https://id.atlassian.com/manage-profile/security/api-tokens

   # .env 파일 업데이트
   nano ~/.claude/.env
   ```

2. Jira URL 확인:
   ```bash
   # URL 형식: yourcompany.atlassian.net (https:// 제외)
   grep ATLASSIAN_URL ~/.claude/.env
   ```

3. Account ID 재확인:
   ```bash
   # productivity-agents.json에서 accountId 확인
   jq '.atlassian.user.accountId' ~/.claude/productivity-agents.json
   ```

### Git author 정보를 찾을 수 없음

**증상**: commit-retrospective 에이전트가 author 정보를 찾지 못함

**원인**:
- Git 전역 설정이 없음
- 프로젝트별 설정도 없음

**해결 방법**:

1. Git 전역 설정:
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "user@company.com"
   ```

2. 또는 프로젝트별 설정:
   ```bash
   cd /your/project
   git config user.name "Your Name"
   git config user.email "user@company.com"
   ```

3. 또는 전역 설정 파일에 추가:
   ```bash
   # ~/.claude/productivity-agents.json
   {
     "github": {
       "user": {
         "username": "yourname",
         "email": "user@company.com"
       }
     }
   }
   ```

### 회고록 저장 실패

**증상**: 회고록 파일 생성 중 권한 오류

**원인**:
- 저장 경로의 쓰기 권한이 없음
- 디렉토리가 존재하지 않음

**해결 방법**:

1. 디렉토리 생성 및 권한 확인:
   ```bash
   mkdir -p ~/.claude/retrospectives
   chmod 755 ~/.claude/retrospectives
   ```

2. 또는 다른 경로로 변경:
   ```bash
   # productivity-agents.json 수정
   jq '.output.retrospectivePath = "/new/path"' \
      ~/.claude/productivity-agents.json > /tmp/config.json
   mv /tmp/config.json ~/.claude/productivity-agents.json
   ```

### 설정이 인식되지 않음

**증상**: 에이전트가 매번 설정을 물어봄

**원인**:
- 설정 파일 경로가 잘못됨
- JSON 형식 오류

**해결 방법**:

1. 설정 파일 경로 확인:
   ```bash
   ls -la ~/.claude/productivity-agents.json
   ```

2. JSON 형식 검증:
   ```bash
   jq empty ~/.claude/productivity-agents.json
   ```

3. 설정 재실행:
   ```bash
   cd ~/.claude/plugins/marketplaces/ahngbeom-claude-config/plugins/productivity-agents
   ./setup/init.sh
   ```

---

## ❓ FAQ

### Q1. 여러 Jira 인스턴스를 사용할 수 있나요?

**A**: 현재 버전에서는 하나의 Jira 인스턴스만 지원합니다. 추후 버전에서 다중 인스턴스 지원이 추가될 예정입니다.

### Q2. GitHub와 GitLab을 동시에 사용할 수 있나요?

**A**: 네, 가능합니다. 전역 설정에 두 플랫폼 정보를 모두 입력하고, 프로젝트별로 `repositories` 배열에 여러 레포지토리를 추가할 수 있습니다.

```json
{
  "productivityAgents": {
    "repositories": [
      {
        "name": "frontend",
        "type": "github",
        "owner": "company",
        "repo": "frontend"
      },
      {
        "name": "backend",
        "type": "gitlab",
        "url": "gitlab.com",
        "path": "company/backend"
      }
    ]
  }
}
```

### Q3. API 토큰을 안전하게 관리하려면?

**A**: `.env` 파일은 민감 정보를 포함하므로 다음 조치를 권장합니다:

1. 파일 권한 제한:
   ```bash
   chmod 600 ~/.claude/.env
   ```

2. Git에 커밋하지 않기:
   ```bash
   # .gitignore에 추가
   .env
   .env.local
   .claude/.env
   ```

3. 주기적으로 토큰 갱신

### Q4. 프로젝트별 설정 없이도 사용 가능한가요?

**A**: 네, 전역 설정만으로도 사용 가능합니다. 프로젝트별 설정은 다음의 경우에만 필요합니다:
- 프로젝트별로 다른 Jira 프로젝트 키를 사용
- 다중 레포지토리 관리
- 프로젝트별 회고록 저장 경로 커스터마이징

### Q5. 설정을 업데이트하려면?

**A**: `init.sh`를 다시 실행하면 기존 설정을 백업하고 새로운 설정으로 업데이트됩니다:

```bash
cd ~/.claude/plugins/marketplaces/ahngbeom-claude-config/plugins/productivity-agents
./setup/init.sh
```

기존 설정은 `productivity-agents.json.backup.YYYYMMDD_HHMMSS` 형식으로 백업됩니다.

### Q6. 다른 팀원과 설정을 공유하려면?

**A**: 프로젝트 설정(`.claude/settings.local.json`)은 팀과 공유할 수 있지만, 전역 설정과 `.env` 파일은 개인 정보이므로 공유하지 마세요.

**공유 가능**:
- `.claude/settings.local.json` (레포지토리 정보, Jira 프로젝트 키)

**공유 불가**:
- `~/.claude/productivity-agents.json` (개인 계정 정보)
- `~/.claude/.env` (API 토큰)

### Q7. Account ID를 어떻게 확인하나요?

**A**: Atlassian Account ID는 다음 방법으로 확인할 수 있습니다:

1. **자동 조회** (권장):
   - `init.sh` 실행 시 "AUTO_DETECT_VIA_MCP"로 설정
   - 에이전트 첫 실행 시 MCP 도구로 자동 조회

2. **수동 확인**:
   - Jira 프로필 페이지 URL에서 확인
   - URL 형식: `https://yourcompany.atlassian.net/jira/people/ACCOUNT_ID`

3. **API 호출**:
   ```bash
   curl -u user@company.com:API_TOKEN \
        https://yourcompany.atlassian.net/rest/api/3/myself
   ```

---

## 📚 추가 리소스

- [Atlassian API 문서](https://developer.atlassian.com/cloud/jira/platform/rest/v3/)
- [GitHub API 문서](https://docs.github.com/en/rest)
- [GitLab API 문서](https://docs.gitlab.com/ee/api/)
- [Claude Code 공식 문서](https://github.com/anthropics/claude-code)

---

## 🆘 지원

문제가 발생하거나 질문이 있으면:

1. 이 가이드의 트러블슈팅 섹션을 확인하세요
2. `validate.sh`를 실행하여 설정을 검증하세요
3. GitHub Issues에 문의하세요: https://github.com/Ahngbeom/claude-config/issues

---

**마지막 업데이트**: 2026-01-29
**버전**: 1.0.0
