#!/usr/bin/env bash
# ~/work 원본 checkout마다 canonical_pin.py를 reference-transaction 훅으로 링크한다.
# core.hooksPath(husky 등)를 쓰는 저장소는 그 디렉터리에 링크한다. --check는 바꾸지 않고 상태만 출력한다.
set -euo pipefail

hook="$(cd "$(dirname "$0")" && pwd)/canonical_pin.py"
[[ -x "$hook" ]] || { echo "실행 권한 없음: $hook (git이 훅을 건너뛴다)" >&2; exit 1; }
check=0
[[ "${1:-}" == --check ]] && check=1

for top in "$HOME"/work/*/; do
  top=${top%/}
  [[ -d "$top/.git" ]] || continue
  hooks=$(git -C "$top" rev-parse --path-format=absolute --git-path hooks)
  dest="$hooks/reference-transaction"
  if [[ "$(readlink "$dest" 2>/dev/null)" == "$hook" ]]; then
    state=ok
  elif [[ -e "$dest" || -L "$dest" ]]; then
    state="skip: 다른 훅이 있음"
  elif (( check )); then
    state=missing
  else
    mkdir -p "$hooks"
    ln -s "$hook" "$dest"
    state=installed
  fi
  printf '%-20s %-22s %s\n' "$(basename "$top")" "$state" "$dest"
done
