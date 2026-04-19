#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  detach-template.sh <remote-url> [--branch <name>] [--commit-message <message>] [--skip-push] --yes

Detaches this project from its current Git history by:
  1. removing .git
  2. initializing a fresh repository
  3. creating a single initial commit
  4. adding origin
  5. optionally pushing the branch

Use an already-created, preferably empty remote repository for the push step.

Options:
  --branch <name>            Branch name to initialize (default: main)
  --commit-message <text>    Initial commit message (default: Initial commit)
  --skip-push                Do not push after creating the new repository
  --yes                      Required confirmation flag for the destructive .git removal step
  -h, --help                 Show this help text
EOF
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../../.." && pwd)"

REMOTE_URL=""
BRANCH="main"
COMMIT_MESSAGE="Initial commit"
SHOULD_PUSH=1
CONFIRMED=0

while (($# > 0)); do
  case "$1" in
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
        shift
      else
        echo "Unexpected argument: $1" >&2
        usage >&2
        exit 1
      fi
      ;;
  esac
done

if [[ -z "$REMOTE_URL" ]]; then
  echo "Missing required <remote-url> argument" >&2
  usage >&2
  exit 1
fi

if [[ "$CONFIRMED" -ne 1 ]]; then
  cat >&2 <<EOF
Refusing to continue without --yes.

This operation will remove:
  ${REPO_ROOT}/.git

Remote URL: ${REMOTE_URL}
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
Branch: ${CURRENT_BRANCH}
Origin: ${CURRENT_ORIGIN}
Commit: ${LATEST_COMMIT}
Pushed: ${PUSHED}
EOF
