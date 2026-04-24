---
name: detach-template
description: Detach this template from its source repository and rename package identifiers.
compatibility: Requires bash and git.
---

# Detach Template

Use this skill when a repository created from `bun-mono-template` needs fresh Git history and project-specific package names.

## Usage

```bash
bash .agents/skills/detach-template/scripts/detach-template.sh \
  "<remote-url>" \
  "<new-repo-name>" \
  --scope "@your-scope" \
  --yes
```

Add `--skip-push` when the remote is not ready yet.

## Options

- Default: `@<repo-name>`
- Custom: `--scope "@acme"`
- Branch: `--branch trunk`
- Commit message: `--commit-message "Initial commit"`

## Behavior

- Rewrites `bun-mono-template`, `@bun-mono-template`, and the template GitHub slug outside the skill directory.
- Deletes `.git`.
- Initializes a fresh repository.
- Creates the initial commit.
- Adds the new `origin`.
- Pushes the branch unless `--skip-push` is set.

## Rename Checklist

Verify the detached repository has project-specific references in:

- `package.json` and `packages/*/package.json`
- `justfile`
- `tsconfig.base.json`
- `eslint.config.js`
- `.changeset/config.json`
- user-facing docs such as `README.md` and `CONTRIBUTING.md`

## Verify

```bash
rg -n "bun-mono-template|@bun-mono-template|LucasLeandro1204/bun-mono-template" \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!.agents/skills/detach-template/**' \
  .
```
