#!/usr/bin/env python3
"""Fail when README.md's plugin catalog disagrees with the files under plugins/."""
import fnmatch
import re
import sys
from pathlib import Path

root = Path(sys.argv[1] if len(sys.argv) > 1 else ".")
readme = (root / "README.md").read_text()
errors = []


def frontmatter(path, key):
    block = path.read_text().split("---", 2)[1]
    found = re.search(rf"^{key}: *(\S+)", block, re.M)
    return found.group(1) if found else ""


plugins = {}
for directory in sorted((root / "plugins").iterdir()):
    if not (directory / ".claude-plugin" / "plugin.json").is_file():
        continue
    plugins[directory.name] = {
        "agents": {p.stem: frontmatter(p, "color") for p in (directory / "agents").glob("*.md")},
        "commands": {p.stem for p in (directory / "commands").glob("*.md")},
    }


def plural(count, noun):
    return f"{count} {noun}" + ("" if count == 1 else "s")


def counts_text(agents, commands):
    parts = [plural(n, noun) for n, noun in ((agents, "agent"), (commands, "command")) if n]
    return " + ".join(parts)


total = re.search(r"^## Plugins & Agents \((\d+) total\)", readme, re.M)
actual_total = sum(len(p["agents"]) for p in plugins.values())
if not total or int(total.group(1)) != actual_total:
    errors.append(f"'Plugins & Agents' total should be {actual_total}")

sections = re.split(r"^### ", readme, flags=re.M)
for name, plugin in plugins.items():
    expected = counts_text(len(plugin["agents"]), len(plugin["commands"]))

    section = next((s for s in sections if s.startswith(f"{name} (")), None)
    if section is None:
        errors.append(f"no '### {name} (...)' section")
        continue
    heading = section.splitlines()[0]
    if heading != f"{name} ({expected})":
        errors.append(f"heading '### {heading}' should be '### {name} ({expected})'")

    rows = dict(re.findall(r"^\| `([a-z0-9-]+)` \|.*\| *(\w+) *\|$", section, re.M))
    for agent, color in plugin["agents"].items():
        if agent not in rows:
            errors.append(f"{name}: agent '{agent}' missing from its table")
        elif rows[agent] != color:
            errors.append(f"{name}: '{agent}' color is {color}, README says {rows[agent]}")
    for agent in rows.keys() - plugin["agents"].keys():
        errors.append(f"{name}: table lists '{agent}' but no such agent file")

    tree = re.search(rf"^│   [├└]── {name}/ +# (\d+ (?:agent|command)s?(?: \(.*?\))?(?: \+ \d+ commands?)?)$", readme, re.M)
    tree_counts = re.sub(r" \(.*?\)", "", tree.group(1)) if tree else None
    if tree_counts != expected:
        errors.append(f"structure tree: '{name}/' should say '# {expected}'")

    listed = set(re.findall(rf"^\| `/([a-z0-9_-]+)` \| `{name}` \|", readme, re.M))
    if listed != plugin["commands"]:
        errors.append(f"{name}: Slash Commands table has {sorted(listed)}, files are {sorted(plugin['commands'])}")

for plugin_name, pattern in sorted(set(re.findall(r"\b([a-z]+-agents):([a-z0-9*-]+)", readme))):
    agents = plugins.get(plugin_name, {}).get("agents", {})
    if not fnmatch.filter(agents, pattern):
        errors.append(f"reference '{plugin_name}:{pattern}' matches no agent")

for message in errors:
    print(f"README: {message}")
sys.exit(1 if errors else 0)
