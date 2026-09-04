#!/usr/bin/env python3
"""전역 PreToolUse 가드레일: AI가 외부 Kubernetes를 '변경'하는 명령을 차단한다.

설계
----
- Bash 도구로 실행하려는 명령 문자열 전체를 정규식으로 스캔한다.
  `re.search`이므로 `cd x && kubectl apply`, `helm template . | kubectl apply -f -`
  같은 체이닝/파이프 우회에도 동사를 잡아낸다.
- 읽기 전용 명령(get/describe/logs/top/rollout status/helm list 등)은 매치하지
  않으므로 그대로 허용된다. 즉 AI의 클러스터 '조회' 능력은 유지한다.
- 변경 명령이 감지되면 PreToolUse permissionDecision="deny"를 출력해 실행 자체를
  막는다. 사람이 필요하면 `!` 프리픽스나 터미널에서 직접 실행한다.
- 어떤 예외에도 exit 0(무결정) — 훅 버그가 정상 작업을 막지 않게 한다(fail-open).
  대신 차단 정규식은 보수적으로(의심되면 차단) 둔다.

적용 범위: ~/.claude/settings.json 에 전역 등록되어 cwd와 무관하게 동작한다.
"""

import sys
import json
import re

# 명령 토큰 경계: 줄 시작, 공백, 세미콜론/파이프/앰퍼샌드/괄호, 또는 경로 구분자(/).
# `mykubectl`, `kubectllike` 같은 오탐은 피하고 `/usr/local/bin/kubectl`은 잡는다.
_B = r"(?:^|[\s;&|()/])"

# kubectl 변경(또는 클러스터 접근) 동사. rollout 은 변경 하위명령만.
_KUBECTL_VERBS = (
    r"apply|create|delete|edit|patch|replace|scale|set|label|annotate|"
    r"drain|cordon|uncordon|taint|exec|cp|attach|port-forward|run|debug|"
    r"rollout\s+(?:restart|undo|pause|resume)"
)

PATTERNS = [
    # kubectl <변경동사>. 간극은 같은 명령 세그먼트로 제한([^;&|\n])해서
    # `kubectl get && echo apply`처럼 다른 세그먼트의 단어를 오탐하지 않는다.
    # 파이프된 두 번째 `... | kubectl apply`는 그 세그먼트가 독립 매치된다.
    (re.compile(_B + r"kubectl\b[^;&|\n]*?\b(?:" + _KUBECTL_VERBS + r")\b", re.IGNORECASE),
     "kubectl 변경 명령"),
    # helm install/upgrade/uninstall/delete/rollback
    (re.compile(_B + r"helm\s+(?:install|upgrade|uninstall|delete|rollback)\b", re.IGNORECASE),
     "helm 릴리스 변경 명령"),
    # argocd app sync/delete/create/set/patch/rollback/terminate-op
    (re.compile(_B + r"argocd\s+app\s+(?:sync|delete|create|set|patch|rollback|terminate-op)\b", re.IGNORECASE),
     "argocd app 변경 명령"),
    # argocd proj/repo/cluster create|delete
    (re.compile(_B + r"argocd\s+(?:proj|repo|cluster)\s+(?:create|delete)\b", re.IGNORECASE),
     "argocd 리소스 변경 명령"),
]
# kustomize(build)는 그 자체로 변경이 아니며, 위험한 부분인 `kubectl apply -k`의
# apply 단계가 위 kubectl 패턴으로 이미 잡힌다. 별도 패턴 불필요.


def find_block_reason(command):
    """차단 사유 문자열을 반환. 매치 없으면 None."""
    if not command:
        return None
    for pattern, label in PATTERNS:
        if pattern.search(command):
            return label
    return None


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        # 입력 파싱 실패 → 무결정(기본 동작 유지)
        sys.exit(0)

    if data.get("tool_name") != "Bash":
        sys.exit(0)

    command = (data.get("tool_input") or {}).get("command", "")
    label = find_block_reason(command)
    if not label:
        # 변경 명령 아님 → 아무것도 출력하지 않고 통과
        sys.exit(0)

    reason = (
        f"🚫 외부 Kubernetes를 변경하는 명령({label})은 안전을 위해 차단됩니다. "
        "클러스터 변경이 꼭 필요하면 사람이 직접 `!` 프리픽스나 터미널에서 실행하세요. "
        "읽기 전용 명령(get/describe/logs/top/rollout status 등)은 그대로 사용할 수 있습니다."
    )
    output = {
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": reason,
        }
    }
    print(json.dumps(output, ensure_ascii=False))
    sys.exit(0)


if __name__ == "__main__":
    try:
        main()
    except Exception:
        # 어떤 예외에도 정상 작업을 막지 않는다(fail-open).
        sys.exit(0)
