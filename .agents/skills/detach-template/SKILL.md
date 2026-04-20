---
name: detach-template
description: Detaches a project from template history, replaces identifiers, supports custom scope, and reinitializes git.
compatibility: Requires git.
---

# Detach Template

## Usage

```bash
bash .agents/skills/detach-template/scripts/detach-template.sh \
  "<remote-url>" \
  "<new-repo-name>" \
  --scope "@your-scope" \
  --yes
```

## Scope

- Default: `@<repo-name>`
- Custom: `--scope "@acme"`

## Behavior

- Rewrites template identifiers
- Rewrites scope
- Deletes `.git`
- Reinitializes repo

## Verify

```bash
rg -n "bun-mono-template|@bun-mono-template" .
```
