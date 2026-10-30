#!/usr/bin/env python3
"""~/work 원본 checkout의 고정 브랜치 규칙. guard-work-checkout.py와 git 훅이 함께 쓴다.

고정 브랜치는 `origin/HEAD`, 원격이 없으면 `main`·`master`다.
install-canonical-pin.sh가 이 파일을 원본마다 `reference-transaction` 훅으로 링크한다.
훅은 prepared 단계에서 아래 갱신이 있으면 트랜잭션 전체를 거부한다.

- 원본(main worktree)의 HEAD를 고정 브랜치 밖으로 옮기는 갱신: detach, 다른 브랜치로의 전환
- 고정 브랜치의 삭제와 fast-forward가 아닌 이동(`reset --hard` 되감기, `branch -f`).
  pack-refs·gc가 packed-refs로 옮긴 loose ref를 지우는 정리는 삭제로 보지 않는다
- CANONICAL_PIN_ALLOW=1 이면 통과
- 어떤 예외에도 exit 0(fail-open)
"""

import os
import re
import subprocess
import sys

ALLOW_ENV = "CANONICAL_PIN_ALLOW"
ZERO = re.compile(r"^0+$")


def git_out(top, *args):
    r = subprocess.run(["git", "-C", str(top), *args], capture_output=True, text=True, timeout=5)
    return r.stdout.strip() if r.returncode == 0 else None


def has_origin(top):
    return "origin" in (git_out(top, "remote") or "").split()


def pinned_branch(top):
    if has_origin(top):
        return (git_out(top, "symbolic-ref", "--short", "-q", "refs/remotes/origin/HEAD") or "").removeprefix("origin/") or None
    for name in ("main", "master"):
        if git_out(top, "rev-parse", "--verify", "-q", f"refs/heads/{name}") is not None:
            return name
    return None


def pruned_into_packed(top, old, ref):
    """pack-refs·gc가 packed-refs에 `old`로 옮겨 둔 loose ref를 지우는 갱신인지.

    진짜 삭제는 prepared 단계에서 packed-refs.lock을 잡고, 정리는 잡지 않는다(files 백엔드).
    """
    common_dir = git_out(top, "rev-parse", "--path-format=absolute", "--git-common-dir")
    if not common_dir or ZERO.match(old) or os.path.exists(os.path.join(common_dir, "packed-refs.lock")):
        return False
    try:
        with open(os.path.join(common_dir, "packed-refs")) as f:
            return f"{old} {ref}" in f.read().splitlines()
    except OSError:
        return False


def violations(updates, top, main_head_in_txn):
    """(old, new, ref) 갱신 목록 중 고정 브랜치 규칙을 어기는 것의 설명 목록.

    main_head_in_txn: 이 트랜잭션의 `HEAD`가 원본(main worktree)의 HEAD인지.
    """
    if not any(ref == "HEAD" or ref.startswith("refs/heads/") for _, _, ref in updates):
        return []
    pinned = pinned_branch(top)
    if not pinned:
        return []
    pinned_ref = f"refs/heads/{pinned}"
    found = []
    for old, new, ref in updates:
        if ref == "HEAD" and main_head_in_txn:
            # git 2.46 미만은 심볼릭 ref 갱신을 훅에 넘기지 않아 브랜치 전환은 여기 오지 않는다
            if new.startswith("ref:"):
                if new[4:] != pinned_ref:
                    found.append(f"HEAD를 `{new[4:]}`로 전환")
            elif not ZERO.match(new):
                # commit·ff 동기화는 HEAD와 그 브랜치가 같은 커밋으로 짝지어 오고, detach는 HEAD만 온다
                branch = git_out(top, "symbolic-ref", "-q", "HEAD")
                if (branch, new) not in {(r, n) for _, n, r in updates}:
                    found.append("HEAD를 detach")
        elif ref == pinned_ref:
            if ZERO.match(new):
                if not pruned_into_packed(top, old, ref):
                    found.append(f"`{pinned}` 삭제")
                continue
            cur = git_out(top, "rev-parse", "-q", "--verify", ref)
            if cur and git_out(top, "merge-base", "--is-ancestor", cur, new) is None:
                found.append(f"`{pinned}`를 fast-forward가 아닌 커밋으로 이동")
    return found


def main():
    stdin = sys.stdin.read()
    if len(sys.argv) < 2 or sys.argv[1] != "prepared" or os.environ.get(ALLOW_ENV) == "1":
        return
    updates = [tuple(line.split()) for line in stdin.splitlines() if len(line.split()) == 3]
    top = os.getcwd()
    common_dir = git_out(top, "rev-parse", "--path-format=absolute", "--git-common-dir")
    # git 2.46+의 `worktree add`는 새 worktree의 HEAD도 원본 프로세스에서 `HEAD`로 넘긴다.
    # prepared 단계에는 갱신 대상 ref가 잠겨 있으므로 원본 HEAD의 잠금 파일로 구분한다(files 백엔드)
    main_head = common_dir is not None and os.path.exists(os.path.join(common_dir, "HEAD.lock"))
    found = violations(updates, top, main_head)
    if not found:
        return
    print(
        f"🚫 canonical-pin: 원본 checkout `{top}`의 고정 브랜치 규칙 위반으로 거부합니다: {', '.join(found)}.\n"
        "   다른 브랜치 작업은 ~/work/.worktrees/ 아래 worktree에서 하세요(~/work/CLAUDE.md).\n"
        f"   사람이 롤백하는 경우에만 `{ALLOW_ENV}=1 git ...`로 다시 실행하세요.",
        file=sys.stderr,
    )
    sys.exit(1)


if __name__ == "__main__":
    try:
        main()
    except SystemExit:
        raise
    except Exception:
        sys.exit(0)
