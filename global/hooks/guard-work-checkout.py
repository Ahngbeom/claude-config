#!/usr/bin/env python3
"""PreToolUse 가드레일: ~/work 아래 원본 checkout을 바꾸는 도구 호출을 차단한다.

원본 checkout은 `~/work/<이름>` 중 `.git`이 디렉터리인 곳이다. 작업은
`~/work/.worktrees/` 아래 worktree에서 한다(규약: ~/work/CLAUDE.md).
원본의 고정 브랜치는 `origin/HEAD`, 원격이 없으면 `main`·`master`다.

- Edit/Write/NotebookEdit: 대상 경로가 원본 checkout 안이면 차단
- Bash: `cd`와 `git -C`를 따라가며 원본 checkout에서 실행되는 git 변경 하위명령을 차단.
  셸 리다이렉트·`sed -i` 같은 일반 쓰기는 잡지 않는다
- 예외(추적 파일이 깨끗할 때): 고정 브랜치에서의 `git pull --ff-only`·`git merge --ff-only`
  동기화, 고정 브랜치로 되돌리는 `git switch`·`git checkout`.
  원격이 있으면 동기화 대상은 `origin/<고정 브랜치>`만 허용한다
- CLAUDE_ALLOW_MAIN_CHECKOUT=1 로 시작한 세션은 고정 브랜치를 벗어나는 전환만 차단
- git 훅 우회 변수(canonical_pin.ALLOW_ENV)를 쓰는 Bash 명령은 세션과 무관하게 차단
- 어떤 예외에도 exit 0(fail-open)
"""

import json
import os
import re
import shlex
import sys
from pathlib import Path

from canonical_pin import ALLOW_ENV, git_out, has_origin, pinned_branch

WORK = Path.home() / "work"

MUTATING_GIT = {
    "add", "am", "apply", "checkout", "cherry-pick", "clean", "commit", "merge",
    "mv", "pull", "rebase", "reset", "restore", "revert", "rm", "stash", "submodule", "switch",
}
READ_ONLY_SUBACTIONS = {"stash": {"list", "show"}, "submodule": {"status", "summary"}}
# git 전역 옵션 중 값을 다음 토큰으로 받는 것
GIT_OPTS_WITH_VALUE = {"-c", "--git-dir", "--work-tree", "--namespace", "--exec-path"}
QUIET_FLAGS = {"-q", "--quiet"}
BRANCH_MOVE_FLAGS = {"-", "-b", "-B", "-c", "-C", "--orphan", "--detach", "-d"}

SEGMENT_SPLIT = re.compile(r"&&|\|\||[;|\n]")
ENV_ASSIGN = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*=")
ENV_SETTERS = {"export", "env", "declare", "readonly", "-x"}


def resolve(path, base):
    p = Path(os.path.expanduser(str(path)))
    if not p.is_absolute():
        p = Path(base) / p
    return Path(os.path.normpath(p))


def main_checkout_of(path):
    try:
        rel = path.relative_to(WORK)
    except ValueError:
        return None
    if not rel.parts or rel.parts[0].startswith("."):
        return None
    top = WORK / rel.parts[0]
    return top if (top / ".git").is_dir() else None


def git_mutation(tokens, cwd):
    """git 변경 하위명령이면 (하위명령, 실행 디렉터리, 인자, 전역 옵션 사용 여부), 아니면 None."""
    i = 0
    while i < len(tokens) and ENV_ASSIGN.match(tokens[i]):
        i += 1
    if i >= len(tokens) or os.path.basename(tokens[i]) != "git":
        return None
    i += 1
    run_dir = cwd
    overridden = False
    while i < len(tokens) and tokens[i].startswith("-"):
        if tokens[i] == "-C" and i + 1 < len(tokens):
            run_dir = resolve(tokens[i + 1], run_dir)
            i += 2
        elif tokens[i] in GIT_OPTS_WITH_VALUE:
            overridden = True
            i += 2
        else:
            overridden = True
            i += 1
    if i >= len(tokens) or tokens[i] not in MUTATING_GIT:
        return None
    sub = tokens[i]
    action = tokens[i + 1] if i + 1 < len(tokens) else None
    if action in READ_ONLY_SUBACTIONS.get(sub, ()):
        return None
    return sub, run_dir, tokens[i + 1:], overridden


def split_args(args):
    return [a for a in args if a.startswith("-")], [a for a in args if not a.startswith("-")]


def is_canonical_update(top, sub, args, overridden):
    """고정 브랜치의 ff-only 동기화이거나 고정 브랜치로 되돌리는 전환이면 True."""
    flags, refs = split_args(args)
    pinned = pinned_branch(top)
    if overridden or not pinned or git_out(top, "status", "--porcelain", "--untracked-files=no") != "":
        return False
    if sub in ("switch", "checkout"):
        return refs == [pinned] and set(flags) <= QUIET_FLAGS
    if git_out(top, "symbolic-ref", "--short", "-q", "HEAD") != pinned:
        return False
    if "--ff-only" not in flags or not set(flags) <= QUIET_FLAGS | {"--ff-only"}:
        return False
    if sub == "merge":
        return len(refs) == 1 and (refs[0] == f"origin/{pinned}" or not has_origin(top))
    if sub == "pull":
        if refs == ["origin", pinned]:
            return True
        return refs in ([], ["origin"]) and git_out(top, "rev-parse", "--abbrev-ref", "@{upstream}") == f"origin/{pinned}"
    return False


def names_commit(top, ref):
    if git_out(top, "rev-parse", "--verify", "-q", f"{ref}^{{commit}}") is not None:
        return True
    return bool(git_out(top, "for-each-ref", "--count=1", f"refs/remotes/*/{ref}"))


def leaves_pinned_branch(top, sub, args):
    """원본 HEAD를 고정 브랜치가 아닌 곳으로 옮기는 전환이면 그 고정 브랜치 이름(없으면 '?')."""
    if sub not in ("switch", "checkout") or (sub == "checkout" and "--" in args):
        return None
    flags, refs = split_args(args)
    pinned = pinned_branch(top) or "?"
    if set(flags) & BRANCH_MOVE_FLAGS:
        return pinned
    if not refs or refs[0] == pinned:
        return None
    # `git checkout <경로>`는 파일 복원이라 허용한다. DWIM으로 원격 브랜치를 따라가는 이름은 전환으로 본다
    if sub == "switch" or names_commit(top, refs[0]):
        return pinned
    return None


def sets_pin_escape(tokens):
    """명령 앞 환경변수 할당이나 export·env로 git 훅 우회 변수를 설정하면 True."""
    for t in tokens:
        if t.startswith(f"{ALLOW_ENV}="):
            return True
        if not (ENV_ASSIGN.match(t) or t in ENV_SETTERS):
            return False
    return False


def bash_block_reason(command, cwd, override=False):
    run_dir = Path(cwd)
    for segment in SEGMENT_SPLIT.split(command or ""):
        try:
            tokens = shlex.split(segment)
        except ValueError:
            tokens = segment.split()
        if not tokens:
            continue
        if sets_pin_escape(tokens):
            return f"`{ALLOW_ENV}`로 원본 고정 브랜치 보호를 우회하는 명령"
        if tokens[0] == "cd":
            if len(tokens) > 1 and tokens[1] != "-":
                run_dir = resolve(tokens[1], run_dir)
            continue
        hit = git_mutation(tokens, run_dir)
        if not hit:
            continue
        sub, git_dir, args, overridden = hit
        top = main_checkout_of(git_dir)
        if not top:
            continue
        if override:
            pinned = leaves_pinned_branch(top, sub, args)
            if pinned:
                return f"원본 checkout `{top}`을 고정 브랜치 `{pinned}` 밖으로 옮기는 `git {sub}`"
        elif not is_canonical_update(top, sub, args, overridden):
            return f"원본 checkout `{top}`에서 `git {sub}` 실행"
    return None


def find_block_reason(tool_name, tool_input, cwd, override=False):
    if tool_name == "Bash":
        return bash_block_reason(tool_input.get("command", ""), cwd, override)
    path = tool_input.get("file_path") or tool_input.get("notebook_path")
    if not override and tool_name in ("Edit", "Write", "NotebookEdit") and path:
        top = main_checkout_of(resolve(path, cwd))
        if top:
            return f"원본 checkout `{top}` 안의 파일 수정"
    return None


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        sys.exit(0)

    override = os.environ.get("CLAUDE_ALLOW_MAIN_CHECKOUT") == "1"
    cwd = data.get("cwd") or os.getcwd()
    label = find_block_reason(data.get("tool_name"), data.get("tool_input") or {}, cwd, override)
    if not label:
        sys.exit(0)

    if override:
        reason = (
            f"🚫 {label}은 차단됩니다. 원본 checkout은 CLAUDE_ALLOW_MAIN_CHECKOUT=1 세션에서도 "
            "고정 브랜치를 벗어나지 않습니다. 다른 브랜치 작업은 `~/work/.worktrees/` 아래 worktree에서 하세요."
        )
    else:
        reason = (
            f"🚫 {label}은 차단됩니다. 원본 checkout에서는 읽기·분석과 고정 브랜치 동기화"
            "(`git pull --ff-only`, `git merge --ff-only origin/<고정 브랜치>`), 고정 브랜치로 되돌리는 "
            "`git switch <고정 브랜치>`만 합니다. ~/work/CLAUDE.md 절차대로 "
            "`~/work/.worktrees/<저장소>-<슬러그>`에 worktree를 만들고 EnterWorktree(path=...)로 옮긴 뒤 "
            "작업하세요. 원본 수정이 꼭 필요하면 사용자가 `CLAUDE_ALLOW_MAIN_CHECKOUT=1 claude`로 세션을 "
            "다시 열어야 합니다."
        )
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": reason,
        }
    }, ensure_ascii=False))
    sys.exit(0)


if __name__ == "__main__":
    try:
        main()
    except Exception:
        sys.exit(0)
