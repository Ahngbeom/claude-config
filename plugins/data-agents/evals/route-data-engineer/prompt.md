---
max_turns: 6
allowed_tools: [Agent, Read, Glob, Grep]
---

매일 새벽 S3의 로그 파일을 읽어 정제한 뒤 웨어하우스에 적재하는 Airflow DAG를 작성해줘.
