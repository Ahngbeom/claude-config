# Plugins

External plugins are not included in this repository.

## Recommended Plugins

### anthropic-agent-skills

Collection of skills for document processing, design, and more.

```bash
claude mcp add anthropic-agent-skills -- npx -y @anthropic-ai/claude-code-mcp
```

**Included Skills:**
- `xlsx` - Excel spreadsheet manipulation
- `docx` - Word document processing
- `pptx` - PowerPoint presentation creation
- `pdf` - PDF manipulation
- `canvas-design` - Visual design creation
- `frontend-design` - Frontend UI design (공식 `frontend-design` 플러그인과 동일, 로컬 `frontend-engineer`와는 보완 관계 — 디자인 미학 vs 엔지니어링)
- `algorithmic-art` - Generative art with p5.js
- `mcp-builder` - MCP server development guide
- `skill-creator` - Custom skill creation guide (공식 `skill-creator` 플러그인과 동일)
- `webapp-testing` - Playwright web testing (공식 `playwright` 외부 플러그인과 보완 관계, 로컬 `test-automation-engineer`는 테스트 코드 작성 전문)
