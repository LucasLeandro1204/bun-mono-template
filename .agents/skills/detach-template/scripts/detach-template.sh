#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  detach-template.sh <remote-url> <new-repo-name> [--scope <scope>] [--branch <name>] [--commit-message <message>] [--skip-push] --yes

Detaches this project from its current Git history and renames template identifiers by:
  1. replacing old repository and package name references with the new repository name and scope
  2. removing .git
  3. initializing a fresh repository
  4. creating a single initial commit
  5. adding origin
  6. optionally pushing the branch

Use an already-created, preferably empty remote repository for the push step.

Arguments:
  <remote-url>                New origin URL, for example git@github.com:owner/repo.git
  <new-repo-name>             New repository/package base name, for example acme-platform

Options:
  --scope <scope>             Package scope to use, for example @acme (default: @<new-repo-name>)
  --branch <name>             Branch name to initialize (default: main)
  --commit-message <text>     Initial commit message (default: Initial commit)
  --skip-push                 Do not push after creating the new repository
  --yes                       Required confirmation flag for the destructive .git removal step
  -h, --help                  Show this help text
EOF
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../../.." && pwd)"

OLD_REPO_NAME="bun-mono-template"
OLD_REPO_SLUG="LucasLeandro1204/bun-mono-template"
OLD_SCOPE="@bun-mono-template"
REMOTE_URL=""
NEW_REPO_NAME=""
NEW_SCOPE=""
BRANCH="main"
COMMIT_MESSAGE="Initial commit"
SHOULD_PUSH=1
CONFIRMED=0

escape_replacement() {
  printf '%s' "$1" | sed -e 's/[\\&]/\\\\&/g'
}

normalize_scope() {
  local scope="$1"

  if [[ -z "$scope" ]]; then
    printf '%s' "@${NEW_REPO_NAME}"
    return
  fi

  if [[ "$scope" != @* ]]; then
    scope="@${scope}"
  fi

  printf '%s' "$scope"
}

rename_template_identifiers() {
  local new_repo_name="$1"
  local new_scope="$2"
  local new_repo_slug
  local escaped_old_repo_name
  local escaped_new_repo_name
  local escaped_old_repo_slug
  local escaped_new_repo_slug
  local escaped_old_scope
  local escaped_new_scope
  local file

  new_repo_slug="$(printf '%s' "$REMOTE_URL" | sed -E 's#^(git@github\.com:|https://github\.com/)##; s#\.git$##')"
  if [[ -z "$new_repo_slug" ]]; then
    echo "Unable to determine GitHub repository slug from remote URL: $REMOTE_URL" >&2
    exit 1
  fi

  escaped_old_repo_name="$(escape_replacement "$OLD_REPO_NAME")"
  escaped_new_repo_name="$(escape_replacement "$new_repo_name")"
  escaped_old_repo_slug="$(escape_replacement "$OLD_REPO_SLUG")"
  escaped_new_repo_slug="$(escape_replacement "$new_repo_slug")"
  escaped_old_scope="$(escape_replacement "$OLD_SCOPE")"
  escaped_new_scope="$(escape_replacement "$new_scope")"

  while IFS= read -r -d '' file; do
    sed -i \
      -e "s/${escaped_old_repo_slug}/${escaped_new_repo_slug}/g" \
      -e "s/${escaped_old_scope}/${escaped_new_scope}/g" \
      -e "s/${escaped_old_repo_name}/${escaped_new_repo_name}/g" \
      "$file"
  done < <(find "$REPO_ROOT" \
    -path "$REPO_ROOT/.git" -prune -o \
    -path "$REPO_ROOT/node_modules" -prune -o \
    -path "$REPO_ROOT/.agents/skills/detach-template" -prune -o \
    -type f -print0)
}

while (($# > 0)); do
  case "$1" in
    --scope)
      if (($# < 2)); then
        echo "Missing value for --scope" >&2
        usage >&2
        exit 1
      fi
      NEW_SCOPE="$2"
      shift 2
      ;;
    --branch)
      if (($# < 2)); then
        echo "Missing value for --branch" >&2
        usage >&2
        exit 1
      fi
      BRANCH="$2"
      shift 2
      ;;
    --commit-message)
      if (($# < 2)); then
        echo "Missing value for --commit-message" >&2
        usage >&2
        exit 1
      fi
      COMMIT_MESSAGE="$2"
      shift 2
      ;;
    --skip-push)
      SHOULD_PUSH=0
      shift
      ;;
    --yes)
      CONFIRMED=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --*)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
    *)
      if [[ -z "$REMOTE_URL" ]]; then
        REMOTE_URL="$1"
      elif [[ -z "$NEW_REPO_NAME" ]]; then
        NEW_REPO_NAME="$1"
      else
        echo "Unexpected argument: $1" >&2
        usage >&2
        exit 1
      fi
      shift
      ;;
  esac
done

if [[ -z "$REMOTE_URL" ]]; then
  echo "Missing required <remote-url> argument" >&2
  usage >&2
  exit 1
fi

if [[ -z "$NEW_REPO_NAME" ]]; then
  echo "Missing required <new-repo-name> argument" >&2
  usage >&2
  exit 1
fi

NEW_SCOPE="$(normalize_scope "$NEW_SCOPE")"

if [[ "$CONFIRMED" -ne 1 ]]; then
  cat >&2 <<EOF
Refusing to continue without --yes.

This operation will:
  - replace template identifiers such as ${OLD_REPO_NAME}, ${OLD_SCOPE}/*, and ${OLD_REPO_SLUG}
  - remove ${REPO_ROOT}/.git

Remote URL: ${REMOTE_URL}
New repo name: ${NEW_REPO_NAME}
New scope: ${NEW_SCOPE}
Branch: ${BRANCH}
Push after commit: $(if [[ "$SHOULD_PUSH" -eq 1 ]]; then echo yes; else echo no; fi)
EOF
  exit 2
fi

if ! command -v git >/dev/null 2>&1; then
  echo "git is required but was not found in PATH" >&2
  exit 1
fi

cd "$REPO_ROOT"

rename_template_identifiers "$NEW_REPO_NAME" "$NEW_SCOPE"

if [[ -e .git ]]; then
  rm -rf .git
fi

if ! git init -b "$BRANCH" >/dev/null 2>&1; then
  git init >/dev/null
  git checkout -b "$BRANCH" >/dev/null 2>&1 || git branch -M "$BRANCH" >/dev/null 2>&1
fi

git add -A
git commit -m "$COMMIT_MESSAGE" >/dev/null

git remote add origin "$REMOTE_URL"

PUSHED="no"
if [[ "$SHOULD_PUSH" -eq 1 ]]; then
  git push -u origin "$BRANCH"
  PUSHED="yes"
fi

LATEST_COMMIT="$(git rev-parse HEAD)"
CURRENT_BRANCH="$(git branch --show-current)"
CURRENT_ORIGIN="$(git remote get-url origin)"

cat <<EOF
Detached repository successfully.
Repository root: ${REPO_ROOT}
Renamed template identifiers to repo name: ${NEW_REPO_NAME}
Renamed template identifiers to scope: ${NEW_SCOPE}
Branch: ${CURRENT_BRANCH}
Origin: ${CURRENT_ORIGIN}
Commit: ${LATEST_COMMIT}
Pushed: ${PUSHED}
EOF
