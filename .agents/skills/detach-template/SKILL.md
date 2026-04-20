---
name: detach-template
description: Detaches a project created from this template from the original Git history, replaces template-specific repository and package identifiers with a new repository name, initializes a fresh `main` branch, creates a clean first commit, adds a new `origin`, and optionally pushes it. Use when turning this template into a brand-new repository.
compatibility: Requires git and a pre-created, ideally empty, remote repository reachable via SSH or HTTPS.
---

# Detach Template

Use this skill when the user wants to adopt this repository as a brand-new project with clean Git history and replace the old template naming with their new repository name.

## Collect Before Running

Ask the user for:

- The new remote URL, for example `git@github.com:owner/repo.git`
- The new repository name, for example `acme-platform`
- Whether they want to push immediately
- An optional initial commit message if they do not want the default `Initial commit`

## What This Skill Does

This workflow:

1. Replaces template-specific identifiers such as:
   - `bun-mono-template`
   - `@bun-mono-template/*`
   - `LucasLeandro1204/bun-mono-template`
2. Removes the current `.git` directory
3. Initializes a fresh Git repository
4. Creates a single initial commit
5. Adds the provided remote as `origin`
6. Optionally pushes the selected branch

The new GitHub repository slug is derived from the provided remote URL and used where repository references must be updated, such as `.changeset/config.json`.

## Safety Rules

- This workflow permanently deletes the current `.git` directory.
- This workflow also rewrites template-specific identifiers across the repository before creating the new initial commit.
- Do **not** run it without explicit user confirmation.
- Make sure the destination remote repository already exists and is ideally empty before pushing.
- If the user only wants a local reset, run the script with `--skip-push`.

## Workflow

1. Confirm the remote URL, the new repository name, and that the user wants to replace the existing Git history.
2. After explicit confirmation, run:

   ```bash
   bash .agents/skills/detach-template/scripts/detach-template.sh "<remote-url>" "<new-repo-name>" --yes
   ```

3. Optional flags:

   - `--branch main`
   - `--commit-message "Initial commit"`
   - `--skip-push`

4. Report the result back to the user, including:

   - the repository root
   - the new repository name used for template replacement
   - the current branch
   - the configured `origin`
   - the latest commit hash
   - whether the push completed

## Examples

Push immediately:

```bash
bash .agents/skills/detach-template/scripts/detach-template.sh \
  "git@github.com:owner/new-repo.git" \
  "new-repo" \
  --yes
```

Create the fresh repo locally without pushing yet:

```bash
bash .agents/skills/detach-template/scripts/detach-template.sh \
  "git@github.com:owner/new-repo.git" \
  "new-repo" \
  --skip-push \
  --yes
```

Use a custom initial commit message:

```bash
bash .agents/skills/detach-template/scripts/detach-template.sh \
  "git@github.com:owner/new-repo.git" \
  "new-repo" \
  --commit-message "chore: bootstrap project from template" \
  --yes
```

## Expected Rename Coverage

The rename step is intended to update the common template references in this repository, including:

- package names in `package.json` and `packages/*/package.json`
- internal imports and TypeScript path aliases
- README and contributor documentation references
- lint and local task runner configuration that embeds the old package scope
- Changesets GitHub repository references
- lockfile entries that still contain the old template name

If needed, do a verification scan after running:

```bash
rg -n "bun-mono-template|@bun-mono-template|LucasLeandro1204/bun-mono-template" .
```

Any remaining matches should be reviewed manually.
