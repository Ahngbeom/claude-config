---
max_turns: 6
allowed_tools: [Agent, Read, Glob, Grep]
---

주문 목록 조회가 3초 넘게 걸려. orders 테이블을 status와 created_at으로 거르고 user_id로 조인하는데, 인덱스를 어떻게 잡아야 할지 봐줘.
