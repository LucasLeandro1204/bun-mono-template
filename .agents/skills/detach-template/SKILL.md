---
name: detach-template
description: Detaches a project created from this template from the original Git history by removing `.git`, initializing a fresh `main` branch, creating a clean first commit, adding a new `origin`, and pushing it. Use when turning this template into a brand-new repository.
compatibility: Requires git and a pre-created, ideally empty, remote repository reachable via SSH or HTTPS.
---

# Detach Template

Use this skill when the user wants to adopt this repository as a brand-new project with clean Git history.

## Collect Before Running

Ask the user for:

- The new remote URL, for example `git@github.com:owner/repo.git`
- Whether they want to push immediately
- An optional initial commit message if they do not want the default `Initial commit`

## Safety Rules

- This workflow permanently deletes the current `.git` directory.
- Do **not** run it without explicit user confirmation.
- Make sure the destination remote repository already exists and is ideally empty before pushing.
- If the user only wants a local reset, run the script with `--skip-push`.

## Workflow

1. Confirm the remote URL and that the user wants to replace the existing Git history.
2. After explicit confirmation, run:

   ```bash
   bash .agents/skills/detach-template/scripts/detach-template.sh "<remote-url>" --yes
   ```

3. Optional flags:

   - `--branch main`
   - `--commit-message "Initial commit"`
   - `--skip-push`

4. Report the result back to the user, including:

   - the repository root
   - the current branch
   - the configured `origin`
   - the latest commit hash
   - whether the push completed

## Examples

Push immediately:

```bash
bash .agents/skills/detach-template/scripts/detach-template.sh \
  "git@github.com:owner/new-repo.git" \
  --yes
```

Create the fresh repo locally without pushing yet:

```bash
bash .agents/skills/detach-template/scripts/detach-template.sh \
  "git@github.com:owner/new-repo.git" \
  --skip-push \
  --yes
```

Use a custom initial commit message:

```bash
bash .agents/skills/detach-template/scripts/detach-template.sh \
  "git@github.com:owner/new-repo.git" \
  --commit-message "chore: bootstrap project from template" \
  --yes
```

## Recommended Follow-Up

After detaching, offer to help rename template-specific identifiers such as:

- `bun-mono-template` in package names, imports, README text, and scripts
- `LucasLeandro1204/bun-mono-template` in `.changeset/config.json`

A quick scan can be done with:

```bash
rg -n "bun-mono-template|@bun-mono-template|LucasLeandro1204/bun-mono-template" .
```
