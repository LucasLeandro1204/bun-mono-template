alias a := audit
alias b := build
alias c := check
alias cd := clean-dry-run
alias cs := changeset
alias css := changeset-status
alias d := dev
alias f := format
alias fc := format-check
alias i := install
alias l := lint
alias lf := lint-fix
alias o := outdated
alias s := start
alias tc := typecheck
alias t := test
alias vp := version-packages
alias ws := workspace

# List available project commands
[default]
list:
  @just --list --unsorted

# Install workspace dependencies
install:
  bun install

# Run the app workspace in development mode
dev:
  bun run dev

# Run the built app workspace
start:
  bun run start

# Build all workspaces
build:
  bun run build

# Type-check all workspaces
typecheck:
  bun run typecheck

# Run the test suite
test:
  bun run test

# Audit dependencies for known vulnerabilities
audit:
  bun run audit

# Show available dependency updates
outdated:
  bun run deps:outdated

# Lint the repository
lint:
  bun run lint

# Lint and apply automatic fixes
lint-fix:
  bun run lint:fix

# Format the repository
format:
  bun run format

# Check formatting without writing files
format-check:
  bun run format:check

# Run the main validation suite
check: format-check lint typecheck test build

# Remove install and build artifacts
clean:
  bun run clean

# Preview cleanup targets without deleting files
clean-dry-run:
  bun run clean:dry-run

# Create a changeset for release notes and versioning
changeset:
  bun run changeset

# Show pending changesets and resulting package versions
changeset-status:
  bun run changeset:status

# Apply version bumps from queued changesets
version-packages:
  bun run version-packages

# Run a Bun script in a specific workspace
workspace package +args:
  bun run --filter {{package}} {{args}}
