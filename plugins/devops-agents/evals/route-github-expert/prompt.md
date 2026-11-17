---
max_turns: 6
allowed_tools: [Agent, Read, Glob, Grep]
---

PR이 열리면 lint와 test를 돌리고, main에 머지되면 Docker 이미지를 빌드해 푸시하는 GitHub Actions 워크플로우를 작성해줘.
