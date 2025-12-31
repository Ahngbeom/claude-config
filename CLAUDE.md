# Claude Code Global Configuration

## Summary Instructions

When using compact, focus on:
- Code changes and implementations
- Test output and error messages
- API modifications
- Architectural decisions
- Current task progress and next steps

## Token Optimization Guidelines

### Preferred Patterns
- Use `@file_path` for direct file references
- Specify exact file paths and function names in queries
- Use `/compact` when context reaches 80%+
- Use `/clear` when switching to completely different tasks

### Session Management
- Same project, different feature: `/compact`
- Different project: `/clear`
- Long session (2h+): periodic `/compact` to avoid premium pricing

### Context Monitoring
- Monitor with `/context` command
- Target: keep below 80% before manual compact
- Auto-compact triggers at 95%

## Language Preference

Respond in Korean (한국어) unless explicitly requested otherwise.

## Project References

### Mobidoc 프론트엔드 (환자용 웹)
- **경로**: `/Users/bahn/Flyingdoctor/mobidoc-front/front-patient`
- **용도**: Flutter WebView에서 표시하는 웹 화면 소스코드
- Flutter 앱과 웹 연동 작업 시 함께 참조
