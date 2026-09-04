#!/usr/bin/env bash
# Validate marketplace/plugin/agent/command/skill specs and shared sync.
set -uo pipefail
cd "$(dirname "$0")/.."
fail=0
err() { echo "FAIL: $*"; fail=1; }

VALID_MODELS="haiku sonnet opus"
VALID_COLORS="red blue green yellow purple orange pink cyan"

# 1. JSON validity
for f in .claude-plugin/marketplace.json plugins/config.json $(find plugins -name plugin.json); do
  jq empty "$f" 2>/dev/null || err "invalid JSON: $f"
done

# 2. plugin.json required fields + semver
for f in $(find plugins -name plugin.json); do
  jq -e '.name and .version and .description and .author' "$f" >/dev/null 2>&1 || err "missing fields: $f"
  v=$(jq -r '.version // ""' "$f")
  echo "$v" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$' || err "bad semver ($v): $f"
done

# 3. marketplace <-> plugin consistency
for src in $(jq -r '.plugins[].source' .claude-plugin/marketplace.json); do
  [ -d "$src" ] || err "marketplace source missing: $src"
  mname=$(jq -r --arg s "$src" '.plugins[]|select(.source==$s)|.name' .claude-plugin/marketplace.json)
  pj="$src/.claude-plugin/plugin.json"
  if [ -f "$pj" ]; then
    pname=$(jq -r '.name' "$pj")
    [ "$mname" = "$pname" ] || err "name mismatch: marketplace=$mname plugin=$pname ($src)"
  fi
done

# helper: read a frontmatter field (inline value only)
fm() { awk -v k="$2" '/^---$/{n++; next} n==1 && $0 ~ "^"k":"{sub("^"k": *",""); print; exit}' "$1"; }

# helper: check if a frontmatter key exists with a non-empty value
# handles both inline ("key: value") and block scalar ("key: |" + indented body)
fm_exists() {
  local file="$1" key="$2"
  awk -v k="$2" '
    /^---$/ { n++; next }
    n != 1  { next }
    # key line found
    $0 ~ "^"k":" {
      # extract inline value after "key: " (or "key:|" etc.)
      sub("^"k":[ \t]*","")
      if ($0 != "" && $0 != "|" && $0 != ">") { found=1; exit }
      # block scalar: next non-empty indented line is the body
      block=1; next
    }
    block == 1 {
      if (/^[ \t]+[^ \t]/) { found=1; exit }  # indented body line
      if (/^[^ \t]/)        { exit }            # new key, no body
    }
  END { exit !found }
  ' "$file"
}

# 4. agent frontmatter
for f in $(find plugins -path '*/agents/*.md'); do
  base=$(basename "$f" .md)
  name=$(fm "$f" name); model=$(fm "$f" model); color=$(fm "$f" color)
  [ -n "$name" ] || err "agent no name: $f"
  [ "$name" = "$base" ] || err "agent name!=filename ($name/$base): $f"
  fm_exists "$f" description || err "agent no description: $f"
  echo "$VALID_MODELS" | grep -qw "$model" || err "agent bad model ($model): $f"
  echo "$VALID_COLORS" | grep -qw "$color" || err "agent bad color ($color): $f"
done

# 5. command frontmatter
for f in $(find plugins -path '*/commands/*.md' 2>/dev/null); do
  fm_exists "$f" description || err "command no description: $f"
  grep -qE '^(name|context):' "$f" && err "command has non-standard field: $f"
done

# 6. skill frontmatter (codex + any plugin skills)
for f in $(find . -name SKILL.md -not -path './.git/*'); do
  [ -n "$(fm "$f" name)" ] || err "skill no name: $f"
  fm_exists "$f" description || err "skill no description: $f"
done

# 7. shared sync drift
scripts/sync-shared.sh --check || err "shared references drift"

# 8. script syntax (global/ + scripts/)
for f in global/cleanup.sh scripts/*.sh; do bash -n "$f" 2>/dev/null || err "bash syntax: $f"; done
for f in global/hooks/*.py; do python3 -c 'import ast,sys; ast.parse(open(sys.argv[1]).read())' "$f" 2>/dev/null || err "python syntax: $f"; done

[ "$fail" = 0 ] && echo "VALIDATION PASSED" || echo "VALIDATION FAILED"
exit $fail
